ettings ***
Documentation       Template robot main suite.

Library    RPA.Desktop
Library    RPA.Browser.Selenium
Library    RPA.FTP
Library    RPA.Email.ImapSmtp
Library    RPA.HTTP
Library    RPA.JSON
Library    String
Library    OperatingSystem
Library    RPA.FileSystem

*** Variables ***
${base_url}  http://tools.etsi.org/vnf-lcm-emulator
${VNF-LCM-KEY}    3c8c385b-3d47-49a2-baae-b758e3935271
${Version}    2.0.0 
${VNF-ID}    ca07f422-ead1-4c9c-bdd8-71b22b820644
${FLAVOURID}    df-normal
${NEWFLAVOURID}  df-big
${api_key_str}


*** Tasks ***
api_key_post
    # ${header}=  Create Dictionary  Accept=application/json
    ${response}=  POST  ${base_url}/api_key 
    ${api_key_str}=  Convert JSON to String  ${response.json()}
    Set Global Variable    ${api_key}  ${api_key_str}
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}
    Log To Console    ${api_key_str}
    Should Be Equal As Strings    ${response.status_code}    201
    ${len_key}=  Get Length    ${api_key_str}
    Log To Console    ${len_key}
    Length Should Be    ${api_key_str}    38

GET vnfds
    ${headers}    Create Dictionary    accept=application/zip    VNF-LCM-KEY=${VNF-LCM-KEY}
    ${params}=    Create Dictionary    vnfdSpecification=SOL001
    ${response1}=  GET  ${base_url}/emulator/vnfds    headers=${headers}    params=${params}
    Log To Console    ${response1.content}
    Log To Console    ${response1}

VNF Instances(0.2)
    # Create a New VNF_instance
    ${headers}=    Create Dictionary    accept=application/json    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}   Content-Type=application/json
    ${data}=    Create Dictionary    vnfdId=${VNF-ID}    
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances    json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    201

VNF Instances(0.3)
    #Delete The Created VNF_instance
    Create Session    my_session    ${base_url}
    ${headers}    Create Dictionary    accept=application/json       Version=${Version}  VNF-LCM-KEY=${VNF-LCM-KEY}
    ${url}=        Set Variable          ${base_url}/vnflcm/v2/vnf_instances/03972622-d766-43dd-9727-1400767d4e86
    ${response}=    DELETE On Session    my_session   url=${url}  headers=${headers}
    Log To Console    ${response.content}
    Log To Console    ${response.status_code}

VNF Instance(0.4)
    #Get the VNF instance by its id
    Create Session    my_session    ${base_url}
    ${headers}    Create Dictionary    accept=application/json       Version=${Version}  VNF-LCM-KEY=${VNF-LCM-KEY}
    ${url}=        Set Variable          ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd
    ${response}=    GET On Session    my_session   url=${url}  headers=${headers}
    Log To Console    ${response.content}
    Log To Console    ${response.status_code}
    Should Be Equal As Strings    ${response.status_code}    200

VNF Instance(0.5)
    #PATCH
    Create Session    my_session    ${base_url}
    ${headers}=    Create Dictionary    accept=application/json    Version=${Version}    VNF-LCM-KEY=${VNF-LCM-KEY}
    ${url}=        Set Variable         ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd
    ${json_body}=  Set Variable    "{\"extensions\":{},\"metadata\":{},\"vimConnectionInfo\":{\"additionalProp1\":{\"accessInfo\":null,\"extra\":null,\"interfaceInfo\":null,\"vimId\":null,\"vimType\":\"vimType\"},\"additionalProp2\":{\"accessInfo\":null,\"extra\":null,\"interfaceInfo\":null,\"vimId\":null,\"vimType\":\"vimType\"},\"additionalProp3\":{\"accessInfo\":null,\"extra\":null,\"interfaceInfo\":null,\"vimId\":null,\"vimType\":\"vimType\"}},\"vnfConfigurableProperties\":{},\"vnfInstanceDescription\":\"new_description\",\"vnfInstanceName\":\"new_name\",\"vnfPkgId\":\"new_pkg_id\"}"
    ${response}=   c url=${url}    headers=${headers}    json=${json_body}
    Log    ${response.text}

VNF LCM Operations(0.1)
    #instantiate a instance
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}  Content-Type=application/json
    ${data}=    Create Dictionary    flavourId=${FLAVOURID}    
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd/instantiate    json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

VNF LCM Operations(0.2)
    #change_flavour
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}   Content-Type=application/json
    ${data}=    Create Dictionary    newFlavourId=df-big   
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd/change_flavour   json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

VNF LCM Operations(0.3)
    #terminate
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}  Content-Type=application/json
    ${data}=    Create Dictionary    terminationType=GRACEFUL   
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd/terminate   json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

VNF LCM Operations(0.4)
    #heal
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}  Content-Type=application/json
    ${data}=    Create Dictionary    additionalParams={}
    ${data}=    Create Dictionary    cause=string
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd/heal   json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

VNF LCM Operations(0.5)
    #operate
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}  Content-Type=application/json
    # ${data}=    Create Dictionary    additionalParams={}
    ${data}=    Create Dictionary    changeStateTo=STARTED
    # ${data}=    Create Dictionary    gracefulStopTimeout=0
    # ${data}=    Create Dictionary    stopType=FORCEFUL
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/e42fe09e-a727-449d-a962-25edd87fcddd/operate  json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

VNF LCM Operations(0.6)
    #scale
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}  Content-Type=application/json
    ${data}=    Create Dictionary    aspectId=all
    ${data}=    Create Dictionary    type=SCALE_OUT
    ${data}=    Create Dictionary    numberofSteps=1
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/3e925810-2025-4113-bc6b-99cc1c652cde/scale   json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202

VNF LCM Operations(0.7)
    #scale
    ${headers}=    Create Dictionary    accept=*/*    Version=2.0.0    VNF-LCM-KEY=${VNF-LCM-KEY}  Content-Type=application/json
    ${data}=    Create Dictionary    instantiationLevelId=double
    ${response}=    POST    ${base_url}/vnflcm/v2/vnf_instances/3e925810-2025-4113-bc6b-99cc1c652cde/scale_to_level   json=${data}    headers=${headers}
    Log To Console    ${response.content}
    Should Be Equal As Strings    ${response.status_code}    202
