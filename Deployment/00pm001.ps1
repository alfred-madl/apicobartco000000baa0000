# Main deployment script
param ($tenant = 'apico', $set = 'ba', $project = 'rt', $service = 'co', $version = '00', $lane = '1', $slot = 'g', $environment = 'p', $region = 's', $defaultregion = 's', $subscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c', $defaultsubscription = 'aec9ffa0-e92d-492d-87b7-a26053b2e22c')

$location = switch($region) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $locationkey = switch($region) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

$defaultlocation = switch($defaultregion) {
    's' {'Southeast Asia'; break} 
    'e' {'East Asia'; break} 
}

 $defaultlocationkey = switch($defaultregion) {
    's' {'southeastasia'; break} 
    'e' {'eastasia'; break} 
}

$params = @{
    # ==================
    # API Function Proxy
    # ==================
    api_function_app_0000aa0 =                      -join($tenant,$set,$project,$service,$version,'00','00','a','a','0',$lane,$slot,$environment,$region); 
    api_group_0000ag0 =                             -join($tenant,$set,$project,$service,$version,'00','00','a','g','0',$lane,$slot,$environment,$region);

    # ===============================
    # CosmosDB Global Command Storage
    # ===============================
    command_storage_group_0c00dg0 =                 -join($tenant,$set,$project,$service,$version,'0c','00','d','g','0',$lane,$slot,$environment,$region);
    command_storage_group_loc_0c00dg0l =            $defaultlocation;
    command_storage_group_lkey_0c00dg0k =           $defaultlocationkey;
    command_storage_group_sub_0c00dg0s =            $defaultsubscription;

    command_storage_cdb_account_0c00dc0 =           -join($tenant,$set,$project,$service,$version,'0c','00','d','c','0',$lane,$slot,$environment,$region);
    command_storage_cdb_database_0c00dd0 =          -join($tenant,$set,$project,$service,$version,'0c','00','d','d','0',$lane,$slot,$environment,$region);
    command_storage_cdb_collection_0c00do0 =        -join($tenant,$set,$project,$service,$version,'0c','00','d','o','0',$lane,$slot,$environment,$region);
    command_storage_cdb_tpl_0c00dc0t =              -join ('00', '00', '0', 'c', '0', '.template.json');

    # ===============================
    # Command Handling and Publishing
    # ===============================
    command_handling_group_0c00cg0 =                -join($tenant,$set,$project,$service,$version,'0c','00','c','g','0',$lane,$slot,$environment,$region);
    command_handling_group_loc_0c00cg0l =           $location;
    command_handling_group_lkey_0c00cg0k =          $locationkey;
    command_handling_group_sub_0c00cg0s =           $subscription;


    # Logic Apps to store commands coming in from the function proxy in the global command storage - HTTP trigger wrapper
    command_create_logapp_httptrig_0ccrclh =        -join($tenant,$set,$project,$service,$version,'0c','cr','c','l','h',$lane,$slot,$environment,$region);
    command_create_logapp_httptrig_tpl_0ccrlht =    -join('00','00','0','l','h','.template.json');
    # Logic Apps to store commands coming in from the function proxy in the global command storage - Storage
    command_create_logapp_storage_0ccrcls =         -join($tenant,$set,$project,$service,$version,'0c','cr','c','l','s',$lane,$slot,$environment,$region);
    command_create_logapp_storage_tpl_0ccrlst =     -join('0c','cr','c','l','s','.template.json');

    # Logic Apps API connection for storing new commands in the global command storage
    command_create_cdb_apiconn_0ccrctc =            -join($tenant,$set,$project,$service,$version,'0c','cr','c','t','c',$lane,$slot,$environment,$region);
    command_create_cdb_apiconn_tpl_0ccrctct =       -join('00','00','0','t','c','.template.json');

    # Event Grid Domain for publishing commands to e.g. view processors
    command_publishing_egd_name_0cpbce0 =           -join($tenant,$set,$project,$service,$version,'0c','pb','c','e','0',$lane,$slot,$environment,$region);
    command_publishing_egd_tpl_0cpbce0t =           -join('00','00','0','e','0','.template.json');

    # App Service Plan for Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_appsvcpln_name_0cpbcp0 =     -join($tenant,$set,$project,$service,$version,'0c','pb','c','p','0',$lane,$slot,$environment,$region);
    command_publishing_appsvcpln_tpl_0cpbcp0t =     -join('00','00','0','p','0','.template.json')
    
    # Storage Account for Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_storage_account_0cpbcs0 =    -join($tenant,$set,$project,$service,$version,'0c','pb','c','s','0',$lane,$slot,$environment,$region);
    command_publishing_storage_tpl_0cpbcs0t =       -join('00','00','0','s','0','.template.json')

    # Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_funcapp_name_0cpbca0 =       -join($tenant,$set,$project,$service,$version,'0c','pb','c','a','0',$lane,$slot,$environment,$region);
    command_publishing_funcapp_tpl_0cpbca0t =       -join('00','00','0','a','0','.template.json')
    # Github Repository and Branch for Publishing Function (App) and its Function with CDB Changefeed trigger, Logic Apps have no CDB Changefeed triggers
    command_publishing_funcapp_repos_0cpbca0r =     -join($tenant,$set,$project,$service,$version,'0c','pb','c','a','0','0','0','0','0','.git')
    command_publishing_funcapp_branch_0cpbca0b =    -join($tenant,$set,$project,$service,$version,'0c','pb','c','a','0',$lane,$slot,$environment,$region);
    # Specific CosmosDB trigger lease prefix because different functions could use the same lease collection (we dont do that, but who knows)
    command_publishing_lease_prefix_0cpbca0f =      -join($tenant,$set,$project,$service,$version,'0c','pb','c','a','0',$lane,$slot,$environment,$region);

    # Lease CDB Account / database and collection for Publishing Function and its CDB Changefeed trigger
    command_lease_cdb_account_0c00ccl =             -join($tenant,$set,$project,$service,$version,'0c','pb','c','c','l',$lane,$slot,$environment,$region);
    command_lease_cdb_database_0c00dcl =            -join($tenant,$set,$project,$service,$version,'0c','pb','c','d','l',$lane,$slot,$environment,$region);
    command_lease_cdb_collection_0c00col =          -join($tenant,$set,$project,$service,$version,'0c','pb','c','o','l',$lane,$slot,$environment,$region);
    command_lease_cdb_tpl_0c00cclt =                -join ('00', '00', '0', 'c', 'l', '.template.json');

}

return $params
