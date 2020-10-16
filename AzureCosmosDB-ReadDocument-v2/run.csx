#r "Newtonsoft.Json"
#r "System.Configuration"
#r "Microsoft.Azure.DocumentDB.Core.dll"

using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq; 
using Microsoft.Azure.WebJobs;
using System.Configuration;

private static DocumentClient client;

public static async Task<IActionResult> Run(HttpRequest req, ILogger log, ExecutionContext context)
{
            JObject headers = new JObject();
            JObject queries = new JObject();
            JObject body = new JObject();
            JObject config = new JObject();
            Parameter _req = new Parameter();
            JObject documentData = new JObject();
            JObject documentData2 = new JObject();
            string documentID = string.Empty;

            string[] keys = new string[]
            {
                _Params.CDBRD_ConfigFile,
                _Params.CDBRD_ConfigFile_SettingName,
                _Params.CDBRD_ConnectionString,
				_Params.CDBRD_ConnectionString_SettingName,
                _Params.CDBRD_ConnectionString_ConnectionStringName,
                _Params.CDBRD_Database,
                _Params.CDBRD_Database_SettingName,
                _Params.CDBRD_Collection,
                _Params.CDBRD_Collection_SettingName,
                _Params.CDBRD_PartitionKeyValue,
                _Params.CDBRD_ConsistencyLevel,
                _Params.CDBRD_SessionToken,
                _Params.CDBRD_IdPath,
                _Params.CDBRD_DocumentId,
                _Params.CDBRD_ResultPath,
                _Params.CDBRD_UseMultipleWriteLocations,
                _Params.CDBRD_UseMultipleWriteLocations_SettingName,
                _Params.CDBRD_PreferredLocations,
                _Params.CDBRD_PreferredLocations_SettingName,
                _Params.CDBRD_ConnectionString2,
				_Params.CDBRD_ConnectionString2_SettingName,
                _Params.CDBRD_ConnectionString2_ConnectionStringName,
                _Params.CDBRD_Database2,
                _Params.CDBRD_Database2_SettingName,
                _Params.CDBRD_Collection2,
                _Params.CDBRD_Collection2_SettingName,
                _Params.CDBRD_PartitionKeyValue2,
                _Params.CDBRD_ConsistencyLevel2,
                _Params.CDBRD_SessionToken2,
                _Params.CDBRD_IdPath2,
                _Params.CDBRD_DocumentId2,
                _Params.CDBRD_UseMultipleWriteLocations2,
                _Params.CDBRD_UseMultipleWriteLocations2_SettingName,
                _Params.CDBRD_PreferredLocations2,
                _Params.CDBRD_PreferredLocations2_SettingName
            };

            try
            {
                //Get parameters from header
                try
                {
                    foreach (KeyValuePair<string, Microsoft.Extensions.Primitives.StringValues> obj in req.Headers)
                    {
                        headers.Add(obj.Key, obj.Value.ToString());
                    }

                    headers = JsonConvert.DeserializeObject<JObject>(headers.ToString(), new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                }
                catch (Exception ex)
                {
                    throw new Exception("Prepare header step: " + ex.Message);
                }

                //Get parameters from query string
                try
                {
                    foreach (KeyValuePair<string, Microsoft.Extensions.Primitives.StringValues> obj in req.Query)
                    {
                        queries.Add(obj.Key, WebUtility.UrlDecode(obj.Value));
                    }

                    queries = JsonConvert.DeserializeObject<JObject>(queries.ToString(), new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                }
                catch (Exception ex)
                {
                    throw new Exception("Prepare query string step: " + ex.Message);
                }

                //Get parameters from request body
                try
                {
                    dynamic data = JsonConvert.DeserializeObject(await new StreamReader(req.Body).ReadToEndAsync());
                    body = JsonConvert.DeserializeObject<JObject>(data.ToString(), new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });

                }
                catch (Exception ex)
                {
                    log.LogWarning("Prepare request body step: " + ex.Message);
                }

                //Add parameter to complete main parameter of function.
                foreach (string k in keys)
                {
                    if (headers[k] == null)
                        headers.Add(k, null);

                    if (queries[k] == null)
                        queries.Add(k, null);

                    if (body[k] == null)
                        body.Add(k, null);
                }

                headers = GetValueFromAppSetting(headers, keys);
                queries = GetValueFromAppSetting(queries, keys);
                body = GetValueFromAppSetting(body, keys);

                //Get config, priority body -> query -> header -> config

                object config_file = GetParameterValue(_Params.CDBRD_ConfigFile, headers, body, queries, null);
                if (config_file == null || string.IsNullOrEmpty(config_file.ToString()))
                {
                    string contents = GetContentFile("CDBRD.configure.json", context);

                    if (!string.IsNullOrEmpty(contents))
                    {
                        try
                        {
                            config = JsonConvert.DeserializeObject<JObject>(contents, new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                            config = GetValueFromAppSetting(config, keys);
                        }
                        catch
                        {
                            throw new Exception("Could not convert Configuration file contents to JSON.");
                        }
                        
                    }
                }
                else 
                {
                    string contents = GetContentFile(config_file.ToString(), context);

                    if (!string.IsNullOrEmpty(contents))
                    {
                        try
                        {
                            config = JsonConvert.DeserializeObject<JObject>(contents, new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                            config = GetValueFromAppSetting(config, keys);
                        }
                        catch
                        {
                            throw new Exception("Could not convert Configuration file contents to JSON.");
                        }
                        
                    }
                }

                //Mapping main parameter of function
                _req.CDBRD_ConfigFile = config_file == null ? "CDBRD.configure.json" : config_file.ToString();
                _req.CDBRD_ConnectionString = TryParseString(GetParameterValue(_Params.CDBRD_ConnectionString, headers, body, queries, config));
                _req.CDBRD_Database = TryParseString(GetParameterValue(_Params.CDBRD_Database, headers, body, queries, config));
                _req.CDBRD_Collection = TryParseString(GetParameterValue(_Params.CDBRD_Collection, headers, body, queries, config));
                _req.CDBRD_PartitionKeyValue = TryParseString(GetParameterValue(_Params.CDBRD_PartitionKeyValue, headers, body, queries, config));
                _req.CDBRD_ConsistencyLevel = TryParseString(GetParameterValue(_Params.CDBRD_ConsistencyLevel, headers, body, queries, config));
                _req.CDBRD_SessionToken = TryParseString(GetParameterValue(_Params.CDBRD_SessionToken, headers, body, queries, config));
                _req.CDBRD_IdPath = TryParseString(GetParameterValue(_Params.CDBRD_IdPath, headers, body, queries, config));
                _req.CDBRD_DocumentId = TryParseString(GetParameterValue(_Params.CDBRD_DocumentId, headers, body, queries, config));
                _req.CDBRD_ResultPath = TryParseString(GetParameterValue(_Params.CDBRD_ResultPath, headers, body, queries, config));
                _req.CDBRD_PreferredLocations = TryParseString(GetParameterValue(_Params.CDBRD_PreferredLocations, headers, body, queries, config));
                _req.CDBRD_UseMultipleWriteLocations = TryParseString(GetParameterValue(_Params.CDBRD_UseMultipleWriteLocations, headers, body, queries, config));
                _req.CDBRD_ConnectionString2 = TryParseString(GetParameterValue(_Params.CDBRD_ConnectionString2, headers, body, queries, config));
                _req.CDBRD_Database2 = TryParseString(GetParameterValue(_Params.CDBRD_Database2, headers, body, queries, config));
                _req.CDBRD_Collection2 = TryParseString(GetParameterValue(_Params.CDBRD_Collection2, headers, body, queries, config));
                _req.CDBRD_PartitionKeyValue2 = TryParseString(GetParameterValue(_Params.CDBRD_PartitionKeyValue2, headers, body, queries, config));
                _req.CDBRD_ConsistencyLevel2 = TryParseString(GetParameterValue(_Params.CDBRD_ConsistencyLevel2, headers, body, queries, config));
                _req.CDBRD_SessionToken2 = TryParseString(GetParameterValue(_Params.CDBRD_SessionToken2, headers, body, queries, config));
                _req.CDBRD_IdPath2 = TryParseString(GetParameterValue(_Params.CDBRD_IdPath2, headers, body, queries, config));
                _req.CDBRD_DocumentId2 = TryParseString(GetParameterValue(_Params.CDBRD_DocumentId2, headers, body, queries, config));
                _req.CDBRD_PreferredLocations2 = TryParseString(GetParameterValue(_Params.CDBRD_PreferredLocations2, headers, body, queries, config));
                _req.CDBRD_UseMultipleWriteLocations2 = TryParseString(GetParameterValue(_Params.CDBRD_UseMultipleWriteLocations2, headers, body, queries, config));

                #region -- Main Process --
                //If CDBRD_DocumentId is not available with parameters then we evaluate 
                // CDBRD_IdPath which can be a JSONPointer/ Path into the request body
                if (string.IsNullOrEmpty(_req.CDBRD_DocumentId)){
                    if (!string.IsNullOrEmpty(_req.CDBRD_IdPath))
                    {
                        //Get CDBRD_IdPath and find the value in Request Body.
                        string idPath = _req.CDBRD_IdPath;

                        try
                        {
                            string tmp = body.SelectToken(idPath).ToString();

                            if (!string.IsNullOrEmpty(tmp))
                                documentID = tmp;
                            else
                                throw new Exception("Could not find DocumentID by using IdPath.");
                        }
                        catch
                        {
                            throw new Exception("Could not find DocumentID by using IdPath.");
                        }
                    }
                    else
                    {
                        throw new Exception("Could not find DocumentID by using IdPath.");
                    }
                }
                else
                {
                    documentID = _req.CDBRD_DocumentId;
                }

                if (string.IsNullOrEmpty(_req.CDBRD_ConnectionString))
                    throw new Exception($"Could not find {_Params.CDBRD_ConnectionString}");

                if (string.IsNullOrEmpty(_req.CDBRD_Database))
                    throw new Exception($"Could not find {_Params.CDBRD_Database}");

                if (string.IsNullOrEmpty(_req.CDBRD_Collection))
                    throw new Exception($"Could not find {_Params.CDBRD_Collection}");

                string endpointUrl = string.Empty;
                string authorizationKey = string.Empty;
                (endpointUrl, authorizationKey) = ParseConnectionString(_req.CDBRD_ConnectionString, log);
                var docLink = "dbs/" + _req.CDBRD_Database + "/colls/" + _req.CDBRD_Collection + "/docs/" + documentID;

                ConnectionPolicy connectionPolicy = new ConnectionPolicy();
                if(_req.CDBRD_PreferredLocations!=null)
                {
                    string[] locations = TryParseString(_req.CDBRD_PreferredLocations).Split(',');               
                    foreach (string location in locations)
                    {
                        string temp = location.Replace("[","").Replace("]","").Replace("\"","").Replace("\r\n","");
                        if(!string.IsNullOrEmpty(temp)){
                            connectionPolicy.PreferredLocations.Add(temp);
                            log.LogInformation(temp);
                        }		
                    }
                }
				if (_req.CDBRD_UseMultipleWriteLocations != null && !string.IsNullOrEmpty(_req.CDBRD_UseMultipleWriteLocations.ToString()))
                {
                    bool _val = false;

                    if (bool.TryParse(_req.CDBRD_UseMultipleWriteLocations.ToString(), out _val))
                    {
						connectionPolicy.UseMultipleWriteLocations = _val; 
                    }
                    else
                    {
                        throw new Exception("CDBRD_UseMultipleWriteLocations is not Boolean.");
                    }
                }
                client = new DocumentClient(new Uri(endpointUrl), authorizationKey,connectionPolicy);
                RequestOptions ro = new RequestOptions();
                if (!string.IsNullOrEmpty(_req.CDBRD_PartitionKeyValue))
                {
                    log.LogInformation("Partition Key : [\"" + _req.CDBRD_PartitionKeyValue + "\"]");
                    ro.PartitionKey = new PartitionKey(_req.CDBRD_PartitionKeyValue);
                }

                if (!string.IsNullOrEmpty(_req.CDBRD_SessionToken))
                {
                    log.LogInformation("Session-Token : " + _req.CDBRD_SessionToken);
                    ro.SessionToken = _req.CDBRD_SessionToken;
                }

                if (!string.IsNullOrEmpty(_req.CDBRD_ConsistencyLevel))
                {           
                    string consistent = _req.CDBRD_ConsistencyLevel;
                    consistent = consistent.ToLower().Replace(" ", string.Empty);
                    if (consistent.Contains("strong"))
                        ro.ConsistencyLevel = ConsistencyLevel.Strong;
                    else if (consistent.Contains("bounded"))
                        ro.ConsistencyLevel = ConsistencyLevel.BoundedStaleness;
                    else if (consistent.Contains("session"))
                        ro.ConsistencyLevel = ConsistencyLevel.Session;
                    else if (consistent.Contains("eventual"))
                        ro.ConsistencyLevel = ConsistencyLevel.Eventual;
                    else if (consistent.Contains("consistent"))
                        ro.ConsistencyLevel = ConsistencyLevel.ConsistentPrefix;   
                }

                string received = null;           
                Document doc = await client.ReadDocumentAsync(docLink,ro);
                received = doc.ToString();           

                documentData = JsonConvert.DeserializeObject<JObject>(received, new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                #endregion

                /*We also need support for checking certain values of the document woth parameters (body, query, header, config) like
                CDBRD_checkEqual_xxxxx=somevalue
                where
                xxxxx is a JSONPath or JSONPointer*/
                #region -- 'Check CDBRD_checkEqual_' --
                string symbol_checker = "CDBRD_checkEqual_";
                Dictionary<string, string> dic = new Dictionary<string, string>();

                foreach(KeyValuePair<string, JToken> obj in body)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null? null : obj.Value.ToString());
                    }
                }

                foreach (KeyValuePair<string, JToken> obj in headers)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null ? null : obj.Value.ToString());
                    }
                }

                foreach (KeyValuePair<string, JToken> obj in queries)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null ? null : obj.Value.ToString());
                    }
                }

                foreach (KeyValuePair<string, JToken> obj in config)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null ? null : obj.Value.ToString());
                    }
                }

log.LogWarning("Matching CDBRD_checkEqual...");
                /** Matching document data**/
                foreach (KeyValuePair<string, string> j in dic)
                {
                    string path = j.Key.Replace(symbol_checker, string.Empty);
                    string test = string.Empty;

                    path = path.TrimStart('$','.','/');
                    path = path.TrimStart('$','.','/');

                    log.LogInformation("----------------------------");
                    log.LogWarning($"{j.Key} -> {path}");
                    path = path.Replace("/",".");
                    try
                    {
                        test = documentData.SelectToken(path).ToString();
                        log.LogWarning($"Comparing data (HTTP request and Document): {j.Value.ToString()} -> {test}");
                    }
                    catch
                    {
                        throw new Exception($"Could not find document with key {j.Key}");
                    }

                    if (!j.Value.ToString().Equals(test))
                    {
                        try
                        {
                            JObject req_val = JObject.Parse(j.Value.ToString());
                            JObject doc_val = JObject.Parse(test);

                            if(!req_val.Equals(doc_val))
                                throw new Exception($"Document does not match with {j.Key}");
                        }
                        catch
                        {
                            throw new Exception($"Document does not match with {j.Key}");
                        }
                    }
                }
                #endregion

                /// read document 2
            if(!string.IsNullOrEmpty(_req.CDBRD_ConnectionString2)&&!string.IsNullOrEmpty(_req.CDBRD_Database2)&&!string.IsNullOrEmpty(_req.CDBRD_Collection2))
            {
                //If CDBRD_DocumentId is not available with parameters then we evaluate 
                // CDBRD_IdPath which can be a JSONPointer/ Path into the request body
                if (string.IsNullOrEmpty(_req.CDBRD_DocumentId2)){
                    if (!string.IsNullOrEmpty(_req.CDBRD_IdPath2))
                    {
                        //Get CDBRD_IdPath and find the value in Request Body.
                        string idPath = _req.CDBRD_IdPath2;

                        try
                        {
                            string tmp = body.SelectToken(idPath).ToString();

                            if (!string.IsNullOrEmpty(tmp))
                                documentID = tmp;
                            else
                                throw new Exception("Could not find DocumentID2 by using IdPath2.");
                        }
                        catch
                        {
                            throw new Exception("Could not find DocumentID2 by using IdPath2.");
                        }
                    }
                    else
                    {
                        throw new Exception("Could not find DocumentID2 by using IdPath2.");
                    }
                }
                else
                {
                    documentID = _req.CDBRD_DocumentId2;
                }

                endpointUrl = string.Empty;
                authorizationKey = string.Empty;
                (endpointUrl, authorizationKey) = ParseConnectionString(_req.CDBRD_ConnectionString2, log);
                docLink = "dbs/" + _req.CDBRD_Database2 + "/colls/" + _req.CDBRD_Collection2 + "/docs/" + documentID;

                connectionPolicy = new ConnectionPolicy();
                if(_req.CDBRD_PreferredLocations2!=null)
                {
                    string[] locations = TryParseString(_req.CDBRD_PreferredLocations2).Split(',');               
                    foreach (string location in locations)
                    {
                        string temp = location.Replace("[","").Replace("]","").Replace("\"","").Replace("\r\n","");
                        if(!string.IsNullOrEmpty(temp)){
                            connectionPolicy.PreferredLocations.Add(temp);
                            log.LogInformation(temp);
                        }		
                    }
                }
				if (_req.CDBRD_UseMultipleWriteLocations2 != null && !string.IsNullOrEmpty(_req.CDBRD_UseMultipleWriteLocations2.ToString()))
                {
                    bool _val = false;

                    if (bool.TryParse(_req.CDBRD_UseMultipleWriteLocations2.ToString(), out _val))
                    {
						connectionPolicy.UseMultipleWriteLocations = _val; 
                    }
                    else
                    {
                        throw new Exception("CDBRD_UseMultipleWriteLocations2 is not Boolean.");
                    }
                }
                client = new DocumentClient(new Uri(endpointUrl), authorizationKey,connectionPolicy);
                ro = new RequestOptions();
                if (!string.IsNullOrEmpty(_req.CDBRD_PartitionKeyValue2))
                {
                    log.LogInformation("Partition Key2 : [\"" + _req.CDBRD_PartitionKeyValue2 + "\"]");
                    ro.PartitionKey = new PartitionKey(_req.CDBRD_PartitionKeyValue2);
                }

                if (!string.IsNullOrEmpty(_req.CDBRD_SessionToken2))
                {
                    log.LogInformation("Session-Token2 : " + _req.CDBRD_SessionToken2);
                    ro.SessionToken = _req.CDBRD_SessionToken2;
                }

                if (!string.IsNullOrEmpty(_req.CDBRD_ConsistencyLevel2))
                {           
                    string consistent = _req.CDBRD_ConsistencyLevel2;
                    consistent = consistent.ToLower().Replace(" ", string.Empty);
                    if (consistent.Contains("strong"))
                        ro.ConsistencyLevel = ConsistencyLevel.Strong;
                    else if (consistent.Contains("bounded"))
                        ro.ConsistencyLevel = ConsistencyLevel.BoundedStaleness;
                    else if (consistent.Contains("session"))
                        ro.ConsistencyLevel = ConsistencyLevel.Session;
                    else if (consistent.Contains("eventual"))
                        ro.ConsistencyLevel = ConsistencyLevel.Eventual;
                    else if (consistent.Contains("consistent"))
                        ro.ConsistencyLevel = ConsistencyLevel.ConsistentPrefix;   
                }

                received = null;           
                doc = await client.ReadDocumentAsync(docLink,ro);
                received = doc.ToString();           

                documentData2 = JsonConvert.DeserializeObject<JObject>(received, new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
           

                /*We also need support for checking certain values of the document woth parameters (body, query, header, config) like
                CDBRD_checkEqual_xxxxx=somevalue
                where
                xxxxx is a JSONPath or JSONPointer*/
                #region -- 'Check CDBRD_checkEqual2_' --
                symbol_checker = "CDBRD_checkEqual2_";
                dic = new Dictionary<string, string>();

                foreach(KeyValuePair<string, JToken> obj in body)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null? null : obj.Value.ToString());
                    }
                }

                foreach (KeyValuePair<string, JToken> obj in headers)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null ? null : obj.Value.ToString());
                    }
                }

                foreach (KeyValuePair<string, JToken> obj in queries)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null ? null : obj.Value.ToString());
                    }
                }

                foreach (KeyValuePair<string, JToken> obj in config)
                {
                    if (obj.Key.StartsWith(symbol_checker))
                    {
                        string val = string.Empty;

                        if (!dic.TryGetValue(obj.Key, out val))
                            dic.Add(obj.Key, obj.Value == null ? null : obj.Value.ToString());
                    }
                }

log.LogWarning("Matching CDBRD_checkEqual2...");
                /** Matching document data**/
                foreach (KeyValuePair<string, string> j in dic)
                {
                    string path = j.Key.Replace(symbol_checker, string.Empty);
                    string test = string.Empty;

                    path = path.TrimStart('$','.','/');
                    path = path.TrimStart('$','.','/');

                    log.LogInformation("----------------------------");
                    log.LogWarning($"{j.Key} -> {path}");
                    path = path.Replace("/",".");
                    try
                    {
                        test = documentData2.SelectToken(path).ToString();
                        log.LogWarning($"Comparing data (HTTP request and Document2): {j.Value.ToString()} -> {test}");
                    }
                    catch
                    {
                        throw new Exception($"Could not find document2 with key {j.Key}");
                    }

                    if (!j.Value.ToString().Equals(test))
                    {
                        try
                        {
                            JObject req_val = JObject.Parse(j.Value.ToString());
                            JObject doc_val = JObject.Parse(test);

                            if(!req_val.Equals(doc_val))
                                throw new Exception($"Document2 does not match with {j.Key}");
                        }
                        catch
                        {
                            throw new Exception($"Document2 does not match with {j.Key}");
                        }
                    }
                }
                /// Merge/////
                documentData.Merge(documentData2);
                #endregion
            }
                /*The read document is the body of the result, but if
                CDBRD_ResultPath is defined please put the document in the corresponding JSON suboject.*/
                string ResultPath = _req.CDBRD_ResultPath.TrimStart('$', '.', '/');

                if (!string.IsNullOrEmpty(ResultPath))
                {
                    ResultPath = ResultPath.Replace("/", ".");
                    string[] path = ResultPath.Split('.');
                    for (int i = path.Length - 1; i >= 0; i--)
                        documentData = JObject.Parse("{\"" + path[i] + "\": " + documentData.ToString() + "}");
                }

                return (ActionResult)new OkObjectResult(documentData);
            }
            catch (Exception ex)
            {
                log.LogError(ex.Message);
                return (ActionResult)new BadRequestObjectResult("");
            }
        }

        private class Parameter
        {
            public string CDBRD_ConfigFile { get; set; }
            public string CDBRD_ConnectionString { get; set; }
            public string CDBRD_Database { get; set; }
            public string CDBRD_Collection { get; set; }
            public string CDBRD_PartitionKeyValue { get; set; }
            public string CDBRD_ConsistencyLevel { get; set; }
            public string CDBRD_SessionToken { get; set; }
            public string CDBRD_IdPath { get; set; }
            public string CDBRD_DocumentId { get; set; }
            public string CDBRD_ResultPath { get; set; }
            public object CDBRD_UseMultipleWriteLocations { get; set;}
			public object CDBRD_PreferredLocations { get; set;}
            public string CDBRD_ConnectionString2 { get; set; }
            public string CDBRD_Database2 { get; set; }
            public string CDBRD_Collection2 { get; set; }
            public string CDBRD_PartitionKeyValue2 { get; set; }
            public string CDBRD_ConsistencyLevel2 { get; set; }
            public string CDBRD_SessionToken2 { get; set; }
            public string CDBRD_IdPath2 { get; set; }
            public string CDBRD_DocumentId2 { get; set; }          
            public object CDBRD_UseMultipleWriteLocations2 { get; set;}
			public object CDBRD_PreferredLocations2 { get; set;}
        }

        private static class _Params
        {
            public static string CDBRD_ConfigFile = "CDBRD_ConfigFile";
            public static string CDBRD_ConfigFile_SettingName = "CDBRD_ConfigFile_SettingName";
            public static string CDBRD_ConnectionString = "CDBRD_ConnectionString";
			public static string CDBRD_ConnectionString_SettingName = "CDBRD_ConnectionString_SettingName";
            public static string CDBRD_ConnectionString_ConnectionStringName = "CDBRD_ConnectionString_ConnectionStringName";
            public static string CDBRD_Database = "CDBRD_Database";
            public static string CDBRD_Database_SettingName = "CDBRD_Database_SettingName";
            public static string CDBRD_Collection = "CDBRD_Collection";
            public static string CDBRD_Collection_SettingName = "CDBRD_Collection_SettingName";
            public static string CDBRD_PartitionKeyValue = "CDBRD_PartitionKeyValue";
            public static string CDBRD_ConsistencyLevel = "CDBRD_ConsistencyLevel";
            public static string CDBRD_SessionToken = "CDBRD_SessionToken";
            public static string CDBRD_IdPath = "CDBRD_IdPath";
            public static string CDBRD_DocumentId = "CDBRD_DocumentId";
            public static string CDBRD_ResultPath = "CDBRD_ResultPath";
            public static string CDBRD_UseMultipleWriteLocations = "CDBRD_UseMultipleWriteLocations";
            public static string CDBRD_UseMultipleWriteLocations_SettingName = "CDBRD_UseMultipleWriteLocations_SettingName";
			public static string CDBRD_PreferredLocations = "CDBRD_PreferredLocations";
            public static string CDBRD_PreferredLocations_SettingName = "CDBRD_PreferredLocations_SettingName";
            public static string CDBRD_ConnectionString2 = "CDBRD_ConnectionString2";
			public static string CDBRD_ConnectionString2_SettingName = "CDBRD_ConnectionString2_SettingName";
            public static string CDBRD_ConnectionString2_ConnectionStringName = "CDBRD_ConnectionString2_ConnectionStringName";
            public static string CDBRD_Database2 = "CDBRD_Database2";
            public static string CDBRD_Database2_SettingName = "CDBRD_Database2_SettingName";
            public static string CDBRD_Collection2 = "CDBRD_Collection2";
            public static string CDBRD_Collection2_SettingName = "CDBRD_Collection2_SettingName";
            public static string CDBRD_PartitionKeyValue2 = "CDBRD_PartitionKeyValue2";
            public static string CDBRD_ConsistencyLevel2 = "CDBRD_ConsistencyLevel2";
            public static string CDBRD_SessionToken2 = "CDBRD_SessionToken2";
            public static string CDBRD_IdPath2 = "CDBRD_IdPath2";
            public static string CDBRD_DocumentId2 = "CDBRD_DocumentId2";
            public static string CDBRD_UseMultipleWriteLocations2 = "CDBRD_UseMultipleWriteLocations2";
            public static string CDBRD_UseMultipleWriteLocations2_SettingName = "CDBRD_UseMultipleWriteLocations2_SettingName";
			public static string CDBRD_PreferredLocations2 = "CDBRD_PreferredLocations2";
            public static string CDBRD_PreferredLocations2_SettingName = "CDBRD_PreferredLocations2_SettingName";
        }

        private static JObject GetValueFromAppSetting(JObject obj, string[] keys)
        {
            try
            {
                foreach (string key in keys)
                {
                    string tmp = key.Replace("_SettingName", string.Empty).Replace("_ConnectionStringName", string.Empty).Trim();

                    JToken _token;
                    if (!obj.TryGetValue(key, out _token))
                        obj.Add(key, null);

                    if (key.EndsWith("_SettingName"))
                    {
                        if (string.IsNullOrEmpty(obj[tmp].ToString()))
                            obj[tmp] = GetParameterInApplicationSetting(obj[key].ToString());
                    }
                    else if (key.EndsWith("_ConnectionStringName"))
                    {
                        if (string.IsNullOrEmpty(obj[tmp].ToString()))
                            obj[tmp] = GetParameterInConnectionString(obj[key].ToString());
                    }
                }
            }
            catch { }

            return obj;
        }

        private static string GetParameterInApplicationSetting(string key)
        {
            string result = null;
            try
            {
                result = System.Environment.GetEnvironmentVariable(key);
            }
            catch { }

            return result;
        }

        private static string GetParameterInConnectionString(string key)
        {
            string result = null;
            try
            {
                result = ConfigurationManager.ConnectionStrings[key].ConnectionString;
            }
            catch { }

            return result;
        }

        private static string GetContentFile(string file_path, ExecutionContext context)
        {
            string result = string.Empty;

            if (!string.IsNullOrEmpty(file_path))
            {
                try
                {
                    //Assume the template is url
                    using (WebClient wclient = new WebClient())
                    {
                        result = wclient.DownloadString(file_path);
                    }
                }
                catch
                {
                    try
                    {
                        //Assume the template is local file
                        string path = Path.Combine(context.FunctionDirectory, file_path);
                        result = File.ReadAllText(path);
                    }
                    catch { }
                }

            }

            return result;
        }

        private static string GenerateAuthToken(string verb, string resourceType, string resourceId, string date, string key, string keyType, string tokenVersion)
        {
            var hmacSha256 = new System.Security.Cryptography.HMACSHA256 { Key = Convert.FromBase64String(key) };

            verb = verb ?? "";
            resourceType = resourceType ?? "";
            resourceId = resourceId ?? "";

            string payLoad = string.Format(System.Globalization.CultureInfo.InvariantCulture, "{0}\n{1}\n{2}\n{3}\n{4}\n",
                    verb.ToLowerInvariant(),
                    resourceType.ToLowerInvariant(),
                    resourceId,
                    date.ToLowerInvariant(),
                    ""
            );

            byte[] hashPayLoad = hmacSha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(payLoad));
            string signature = Convert.ToBase64String(hashPayLoad);

            return WebUtility.UrlEncode(String.Format(System.Globalization.CultureInfo.InvariantCulture, "type={0}&ver={1}&sig={2}",
                keyType,
                tokenVersion,
                signature));
        }

        private static (string, string) ParseConnectionString(string connectionString, ILogger log)
        {
            connectionString = connectionString.TrimEnd(';');
            var properties = connectionString.Split(';');

            if (properties.Length > 1)
            {
                var dict = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                foreach (var property1 in properties)
                {
                    var kvp = property1.Split(new char[] { '=' }, 2);
                    if (kvp.Length != 2) continue;

                    var key = kvp[0].Trim();
                    if (dict.ContainsKey(key))
                    {
                        throw new ArgumentException($"Duplicate properties found in connection string: {key}.");
                    }

                    dict.Add(key, kvp[1].Trim());
                }

                if (dict.ContainsKey("AccountEndpoint") && dict.ContainsKey("AccountKey"))
                {
                    return (dict["AccountEndpoint"].TrimEnd('/'), dict["AccountKey"]);
                }
            }

            throw new ArgumentException($"Connection string missing required properties 'endpoint' and 'accesskey'.");
        }

        private static object GetParameterValue(string key, JObject header, JObject body, JObject querystring, JObject config)
        {
            object result = null;

            if (!string.IsNullOrEmpty(key))
            {
                bool hasValue = false;

                /** Matching data from body -> query -> header -> config **/
                if(body != null)
                {
                    foreach (KeyValuePair<string, JToken> obj in body)
                    {
                        if (obj.Key.Equals(key) && (obj.Value != null && !string.IsNullOrEmpty(obj.Value.ToString())))
                        {
                            hasValue = true;
                            result = obj.Value;
                            break;
                        }
                    }
                }

                if (!hasValue && querystring != null && querystring.HasValues)
                {
                    foreach (KeyValuePair<string, JToken> obj in querystring)
                    {
                        if (obj.Key.Equals(key) && (obj.Value != null && !string.IsNullOrEmpty(obj.Value.ToString())))
                        {
                            hasValue = true;
                            result = obj.Value;
                            break;
                        }
                    }
                }

                if (!hasValue && header != null && header.HasValues)
                {
                    foreach (KeyValuePair<string, JToken> obj in header)
                    {
                        if (obj.Key.Equals(key) && (obj.Value != null && !string.IsNullOrEmpty(obj.Value.ToString())))
                        {
                            hasValue = true;
                            result = obj.Value;
                            break;
                        }
                    }
                }

                if (!hasValue && config != null && config.HasValues)
                {
                    foreach (KeyValuePair<string, JToken> obj in config)
                    {
                        if (obj.Key.Equals(key) && (obj.Value != null && !string.IsNullOrEmpty(obj.Value.ToString())))
                        {
                            hasValue = true;
                            result = obj.Value;
                            break;
                        }
                    }
                }
            }

            return result;
        }

        private static string TryParseString(object input)
        {
            if (input != null && !string.IsNullOrEmpty(input.ToString()))
                return input.ToString();

            return null;
        }
 