# Set all names and params
param ([hashtable]$params = @{})

# ==================
# Locations
# ==================
$location = switch($params.region) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $locationkey = switch($params.region) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

$defaultlocation = switch($params.defaultregion) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $defaultlocationkey = switch($params.defaultregion) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

# ==================
# Read Git token
# ==================
$gittoken = Get-Content -Path gittoken.txt | Out-String

# ========================
# Set all params and names
# ========================
$params = $params + @{ 
    # ==================
    # Common params
    # ==================
    location = $location;
    locationkey = $locationkey;
    defaultlocation = $defaultlocation;
    defaultlocationkey = $defaultlocationkey;
    gittoken = $gittoken;
    gitprovider = '/providers/Microsoft.Web/sourcecontrols/GitHub';

    # ==================
    # API Function Proxy
    # ==================
    api_proxy_group_0000ag0 =                       -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','g','0',$params.lane,$params.slot,$params.environment,$params.region);
    api_proxy_group_loc_0000ag0l =                  $location;
    api_proxy_group_lkey_0000ag0k =                 $locationkey;
    api_proxy_group_sub_0000ag0s =                  $params.subscription;

    # App Service Plan for API Function (App) and its Proxies
    api_proxy_appsvcpln_name_0000ap0 =     -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','p','0',$params.lane,$params.slot,$params.environment,$params.region);
    api_proxy_appsvcpln_tpl_0000ap0t =     -join('00','00','0','p','0','.template.json')
    
    # Storage Account for API Function (App)
    api_proxy_storage_account_0000as0 =    -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','s','0',$params.lane,$params.slot,$params.environment,$params.region);
    api_proxy_storage_tpl_0000as0t =       -join('00','00','0','s','0','.template.json')

    # API Function (App)
    api_proxy_funcapp_name_0000aa0 =       -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','a','0',$params.lane,$params.slot,$params.environment,$params.region);
    api_proxy_funcapp_tpl_0000aa0t =       -join('00','00','0','a','0','.template.json')
    # Github Repository and Branch for API Function (App)
    api_proxy_funcapp_repos_0000aa0r =     -join($params.reposprefix,$params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','a','0','0','0','0','0','.git')
    api_proxy_funcapp_branch_0000aa0b =    -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','a','0',$params.lane,$params.slot,$params.environment,$params.region);
    # Function App Settings
    api_proxy_funcapp_extvers_0000aa0v =   '~3'
    api_proxy_funcapp_runtime_0000aa0n =   'dotnet'
    # file share name, same as function name
    api_proxy_funcapp_share_0000aa0s =      -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','a','a','0',$params.lane,$params.slot,$params.environment,$params.region);

    # ===============================
    # CosmosDB Global Command Data
    # ===============================
    command_storage_group_0c00dg0 =                 -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','00','d','g','0',$params.lane,'0','0','0');
    command_storage_group_loc_0c00dg0l =            $defaultlocation;
    command_storage_group_lkey_0c00dg0k =           $defaultlocationkey;
    command_storage_group_sub_0c00dg0s =            $params.defaultsubscription;

    command_storage_cdb_account_0c00dc0 =           -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','00','d','c','0',$params.lane,'0','0','0');
    # Connection String
    # command_storage_cdb_connstr_0c00dc0c
    command_storage_cdb_database_0c00dd0 =          -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','00','d','d','0',$params.lane,'0','0','0');
    command_storage_cdb_collection_0c00do0 =        -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','00','d','o','0',$params.lane,'0','0','0');
    command_storage_cdb_tpl_0c00dc0t =              -join ('0c', '00', 'd', 'c', '0', '.template.json');

    # ===============================
    # Command Handling and Publishing
    # ===============================
    command_handling_group_0c00cg0 =                -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','00','c','g','0',$params.lane,$params.slot,$params.environment,$params.region);
    command_handling_group_loc_0c00cg0l =           $location;
    command_handling_group_lkey_0c00cg0k =          $locationkey;
    command_handling_group_sub_0c00cg0s =           $params.subscription;


    # Logic Apps to store commands coming in from the function proxy in the global command storage - HTTP trigger wrapper
    command_create_logapp_httptrig_0ccrclh =        -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cr','c','l','h',$params.lane,$params.slot,$params.environment,$params.region);
    command_create_logapp_httptrig_tpl_0ccrlht =    -join('00','00','0','l','h','.template.json');
    # trigger name for reading the start URL to put it into afunction app settings for the proxies
    command_create_logapp_httptrig_name_0ccrclhn =       'manual';
    # Logic Apps to store commands coming in from the function proxy in the global command storage - Storage
    command_create_logapp_storage_0ccrcls =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cr','c','l','s',$params.lane,$params.slot,$params.environment,$params.region);
    command_create_logapp_storage_tpl_0ccrlst =     -join('0c','cr','c','l','s','.template.json');

    # Logic Apps CDB API connection for storing new commands in the global command storage
    command_create_cdb_apiconn_0ccrctc =            -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cr','c','t','c',$params.lane,$params.slot,$params.environment,$params.region);
    command_create_cdb_apiconn_tpl_0ccrctct =       -join('00','00','0','t','c','.template.json');

    # Event Grid Domain for publishing commands to e.g. view processors
    command_publishing_egd_name_0cpbce0 =           -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','e','0',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_egd_tpl_0cpbce0t =           -join('00','00','0','e','0','.template.json');

    # App Service Plan for Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_appsvcpln_name_0cpbcp0 =     -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','p','0',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_appsvcpln_tpl_0cpbcp0t =     -join('00','00','0','p','0','.template.json')
    
    # Storage Account for Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_storage_account_0cpbcs0 =    -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','s','0',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_storage_tpl_0cpbcs0t =       -join('00','00','0','s','0','.template.json')

    # Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_funcapp_name_0cpbca0 =       -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','a','0',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_funcapp_tpl_0cpbca0t =       -join('00','00','0','a','0','.template.json')
    # Github Repository and Branch for Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_funcapp_repos_0cpbca0r =     -join($params.reposprefix,$params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','a','0','0','0','0','0','.git')
    command_publishing_funcapp_branch_0cpbca0b =    -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','a','0',$params.lane,$params.slot,$params.environment,$params.region);
    # Specific CosmosDB trigger lease prefix because different functions could use the same lease collection (we dont do that, but who knows)
    # same as function app name
    command_publishing_lease_prefix_0cpbca0f =      -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','a','0',$params.lane,$params.slot,$params.environment,$params.region);
    # Function App Settings
    command_publishing_funcapp_extvers_0cpbca0v =   '~3'
    command_publishing_funcapp_runtime_0cpbca0n =   'dotnet'
    # file share name, same as function name
    command_publishing_funcapp_share_0000aa0s =      -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','a','0',$params.lane,$params.slot,$params.environment,$params.region);

    # Lease CDB Account / database and collection for Publishing Function and its CDB Changefeed trigger
    command_publishing_lease_account_0cpbccl =      -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','c','l',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_lease_database_0cpbdcl =     -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','d','l',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_lease_collection_0cpbcol =   -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pb','c','o','l',$params.lane,$params.slot,$params.environment,$params.region);
    command_publishing_lease_tpl_0cpbcclt =         -join ('0c', 'pb', 'c', 'c', 'l', '.template.json');

    # ===============================
    # Command Clearing
    # ===============================
    command_clear_group_0cclcg0 =                   -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','g','0',$params.lane,$params.slot,$params.environment,$params.region);
    command_clear_group_loc_0cclcg0l =              $location;
    command_clear_group_lkey_0cclcg0k =             $locationkey;
    command_clear_group_sub_0cclcg0s =              $params.subscription;

    # Logic Apps to clear commands in the global command storage - HTTP trigger wrapper
    command_clear_logapp_httptrig_0cclclh =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','l','h',$params.lane,$params.slot,$params.environment,$params.region);
    command_clear_logapp_httptrig_tpl_0ccllht =     -join('00','00','0','l','h','.template.json');
    # Logic Apps to clear commands in the global command storage - EGD trigger wrapper
    command_clear_logapp_egdtrig_0cclclg =          -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','l','g',$params.lane,$params.slot,$params.environment,$params.region);
    command_clear_logapp_egdtrig_tpl_0ccllgt =      -join('00','00','0','l','g','.template.json');
    # Logic Apps to clear commands in the global command storage - Deletion
    command_clear_logapp_deletion_0cclcld =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','l','d',$params.lane,$params.slot,$params.environment,$params.region);
    command_clear_logapp_deletion_tpl_0cclldt =     -join('0c','cl','c','l','d','.template.json');

    # Logic Apps API CDB API connection for clearing commands in the global command storage
    command_clear_cdb_apiconn_0cclctc =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','t','c',$params.lane,$params.slot,$params.environment,$params.region);
    command_clear_cdb_apiconn_tpl_0cclctct =        -join('00','00','0','t','c','.template.json');

    # Logic Apps API EGD API connection for clearing commands to the command publishing event grid domain
    command_clear_egd_apiconn_0cclctg =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','t','g',$params.lane,$params.slot,$params.environment,$params.region);
    command_clear_egd_apiconn_tpl_0cclctgt =        -join('00','00','0','t','g','.template.json');
    # Logic Apps EGD topic for clearing commands
    command_clear_egd_topic_0cclctg =               -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','b','0',$params.lane,$params.slot,$params.environment,$params.region);

    # Logic Apps EGD topic subscription
    # same as logic app name
    command_clear_logapp_egdtrig_0cclclgs =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','l','g',$params.lane,$params.slot,$params.environment,$params.region);

    # Logic Apps AAD app registration for EGD subscription
    # same as logic app name
    command_clear_logapp_egdtrig_0cclclgr =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','l','g',$params.lane,$params.slot,$params.environment,$params.region);
    # Logic Apps AAD app uri for EGD subscription
    # contains logic app name
    command_clear_logapp_egdtrig_0cclclgu =         -join('https://',$params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','cl','c','l','g',$params.lane,$params.slot,$params.environment,$params.region,'.apico.io');
    # Logic Apps AAD app password for EGD subscription
    command_clear_logapp_egdtrig_0cclclgp =         [guid]::NewGuid().Guid;
    # Logic Apps AAD app password begin for EGD subscription
    command_clear_logapp_egdtrig_0cclclgb =         $params.now;
    # Logic Apps AAD app password end for EGD subscription
    command_clear_logapp_egdtrig_0cclclge =         $params.now.AddYears(2);

    # ===============================
    # Read View
    # ===============================
    read_view_group_0000rg0 =                   -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','r','g','0',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_group_loc_0000rg0l =              $location;
    read_view_group_lkey_0000rg0k =             $locationkey;
    read_view_group_sub_0000rg0s =              $params.subscription;

    read_view_cdb_account_0000rc0 =           -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','r','c','0',$params.lane,'0','0','0');
    # Connection String
    # read_view_cdb_connstr_0000rc0c
    read_view_cdb_database_0000rd0 =          -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','r','d','0',$params.lane,'0','0','0');
    read_view_cdb_collection_0000ro0 =        -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','00','r','o','0',$params.lane,'0','0','0');
    read_view_cdb_tpl_0000rc0t =              -join ('00', '00', 'r', 'c', '0', '.template.json');


    # Logic Apps to process commands from the global command storage - HTTP trigger wrapper
    read_view_logapp_httptrig_00prrlh =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','l','h',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_logapp_httptrig_tpl_00prlht =     -join('00','00','0','l','h','.template.json');
    # Logic Apps to process commands from the global command storage - EGD trigger wrapper
    read_view_logapp_egdtrig_00prrlg =          -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','l','g',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_logapp_egdtrig_tpl_00prlgt =      -join('00','00','0','l','g','.template.json');
    # Logic Apps to process commands in the global command storage - Sync
    read_view_logapp_sync_00prrls =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','l','s',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_logapp_sync_tpl_00prlst =         -join('00','pr','r','l','s','.template.json');

    # Logic Apps execute one command in the read view - HTTP trigger wrapper
    read_view_logapp_httptrig_00exrlh =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','ex','r','l','h',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_logapp_httptrig_tpl_00exlht =     -join('00','00','0','l','h','.template.json');
    # Logic Apps to execute one command in the read view - Write
    read_view_logapp_write_00exrlw =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','ex','r','l','w',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_logapp_write_tpl_00exlwt =         -join('00','ex','r','l','w','.template.json');

    # Logic Apps - Write - API CDB API connection for writing objects to the read view
    read_view_cdb_apiconn_00exrtc =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','ex','r','t','c',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_cdb_apiconn_tpl_00exrtct =        -join('00','00','0','t','c','.template.json');

    # Logic Apps - Sync - API CDB API connection for reading commands from the global command storage
    read_view_cdb_apiconn_00prrtc =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','t','c',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_cdb_apiconn_tpl_00prrtct =        -join('00','00','0','t','c','.template.json');

    # Logic Apps - API EGD API connection for processing commands to the command publishing event grid domain
    read_view_egd_apiconn_00prrtg =             -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','t','g',$params.lane,$params.slot,$params.environment,$params.region);
    read_view_egd_apiconn_tpl_00prrtgt =        -join('00','00','0','t','g','.template.json');
    # Logic Apps EGD topic for processing commands
    read_view_egd_topic_00prrtg =               -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'0c','pr','c','b','0',$params.lane,$params.slot,$params.environment,$params.region);

    # Logic Apps EGD topic subscription
    # same as logic app name
    read_view_logapp_egdtrig_00prrlgs =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','l','g',$params.lane,$params.slot,$params.environment,$params.region);

    # Logic Apps AAD app registration for EGD subscription
    # same as logic app name
    read_view_logapp_egdtrig_00prrlgr =         -join($params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','l','g',$params.lane,$params.slot,$params.environment,$params.region);
    # Logic Apps AAD app uri for EGD subscription
    # contains logic app name
    read_view_logapp_egdtrig_00prrlgu =         -join('https://',$params.tenant,$params.set,$params.project,$params.service,$params.version,'00','pr','r','l','g',$params.lane,$params.slot,$params.environment,$params.region,'.apico.io');
    # Logic Apps AAD app password for EGD subscription
    read_view_logapp_egdtrig_00prrlgp =         [guid]::NewGuid().Guid;
    # Logic Apps AAD app password begin for EGD subscription
    read_view_logapp_egdtrig_00prrlgb =         $params.now;
    # Logic Apps AAD app password end for EGD subscription
    read_view_logapp_egdtrig_00prrlge =         $params.now.AddYears(2);
}

# Level 2 name and params
$params = $params + @{ 
    # ===============================
    # Command Handling and Publishing
    # ===============================
    # Event Grid Domain for publishing commands to e.g. view processors SCOPE for role assignments of AAD App
    command_publishing_egd_scope_0cpbce0s =  -join("/subscriptions/",$params.command_handling_group_sub_0c00cg0s,"/resourceGroups/",$params.command_handling_group_0c00cg0,"/providers/Microsoft.EventGrid/domains/",$params.command_publishing_egd_name_0cpbce0);
}
return $params