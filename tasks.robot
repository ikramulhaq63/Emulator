*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Desktop
Library             RPA.Browser.Selenium
Library             RPA.FTP
Library             RPA.Email.ImapSmtp
Library             RPA.HTTP
Library             RPA.JSON
Library             String
Library             Collections
Resource            Resource.robot


*** Tasks ***
api_key_post
    # ${header}=    Create Dictionary    Accept=application/json
    ${response}=    POST    ${base_url}/api_key
    ${api_key_str}=    Convert JSON to String    ${response.json()}
    Set Global Variable    $api_key    ${api_key_str}
    Log To Console    ${response.status_code}
    Log To Console    ${api_key}
    Set Global Variable    $apikey    ${api_key.replace('"', '')}
    Log To Console    ${apikey}
    Should Be Equal As Strings    ${response.status_code}    201

Get Available Descriptor
    ${headers}=    Create Dictionary    accept=application/zip    VNF-LCM-KEY=${api_key}
    ${params}=    Create Dictionary    vnfdSpecification=SOL006
    ${response}=    GET    ${base_url}/emulator/vnfds    headers=${headers}    params=${params}
    Log To Console    ${response.content}
    Log To Console    ${response}

Creating VNF
    ${headers}=    Create Dictionary
    ...    accept=application/json
    ...    Version=2.0.0
    ...    VNF-LCM-KEY=${api_key}
    ...    Content-Type=application/json
    ${data}=    evaluate    json.loads('''${json_body}''')    json
    # ${data}=    Create Dictionary    vnfdId=${vnfdid}
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances    json=${data}    headers=${headers}
    Log To Console    ${response}
    Log To Console    ${response.content}
    ${response_dict}=    Evaluate    json.loads('''${response.content}''')
    ${vnf_instance_id}=    Get From Dictionary    ${response_dict}    id
    Set Global Variable    $vnf_id    ${vnf_instance_id}
    Log To Console    ${vnf_instance_id}
    Log To Console    ${response.status_code}
    Should Be Equal As Strings    ${response.status_code}    201

Instantiate VNF Instance
    ${flavour-id}=    Create Dictionary    flavourId=df-normal
    ${headers}=    Create Dictionary
    ...    accept=*/*
    ...    Version=2.0.0
    ...    VNF-LCM-KEY=${api_key}
    ...    Content-Type=application/json
    ${response}=    POST
    ...    ${base_url}/vnflcm/v2/vnf_instances/${vnf_id}/instantiate
    ...    json=${flavour-id}
    ...    headers=${headers}
    Log To Console    ${response}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

Terminate VNF Instance
    Sleep    50
    ${terminationtype}=    Create Dictionary    terminationType=FORCEFUL
    ${headers}=    Create Dictionary
    ...    accept=*/*
    ...    Version=2.0.0
    ...    VNF-LCM-KEY=${api_key}
    ...    Content-Type=application/json
    ${response}=    POST
    ...    ${base_url}/vnflcm/v2/vnf_instances/${vnf_id}/terminate
    ...    json=${terminationtype}
    ...    headers=${headers}
    Log To Console    ${response}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

Delete VNF Instance
    Sleep    60
    ${headers}=    Create Dictionary
    ...    accept=*/*
    ...    Version=2.0.0
    ...    VNF-LCM-KEY=${api_key}
    ${url}=    Set Variable    ${base_url}/vnflcm/v2/vnf_instances/${vnf_id}
    Create Session    VNFLCM    ${url}
    ${response}=    DELETE On Session    VNFLCM
    ...    url=${url}
    ...    headers=${headers}
    Log To Console    ${response}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    204
