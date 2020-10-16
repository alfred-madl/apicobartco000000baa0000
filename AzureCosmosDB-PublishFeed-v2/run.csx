#r "Microsoft.Azure.DocumentDB.Core"
#r "Newtonsoft.Json"
#r "System.Configuration"

using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using Microsoft.Azure.Documents;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq; 
using System.Configuration;

public static void Run(IReadOnlyList<Document> documents, ILogger log, ExecutionContext context)
{
    DateTime dt_now = DateTime.UtcNow;
            string time_now_milisec = dt_now.ToString("yyyy-MM-ddTHH:mm:ss.fffZ");

            if (documents != null && documents.Count > 0)
            {
                foreach (var doc in documents)
                {
                    JObject json_data = new JObject();

                    try
                    {
                        json_data = JsonConvert.DeserializeObject<JObject>(doc.ToString(), new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                    }
                    catch
                    {
                        log.LogError("This function support only documents in JSON format.");
                        log.LogInformation("");
                        log.LogInformation("......................");

                        throw new Exception("This function support only documents in JSON format.");
                    }

                    string config_file = System.Environment.GetEnvironmentVariable("CDBPF_Configuration");
                    string event_topic_endpoint = System.Environment.GetEnvironmentVariable("CDBPF_Event_TopicEndpoint");
                    string event_topic_key = System.Environment.GetEnvironmentVariable("CDBPF_Event_TopicKey");
                    string event_subject = System.Environment.GetEnvironmentVariable("CDBPF_Event_Subject_Path");
                    string event_type = System.Environment.GetEnvironmentVariable("CDBPF_Event_Type");
                    string event_type_path = System.Environment.GetEnvironmentVariable("CDBPF_Event_Type_Path");
                    string event_id = System.Environment.GetEnvironmentVariable("CDBPF_Event_ID_Path");
                    string event_time_path = System.Environment.GetEnvironmentVariable("CDBPF_Event_Time_Path");
                    string event_time_prefix = System.Environment.GetEnvironmentVariable("CDBPF_Event_Time_Prefix");
                    string event_time_prefix_path = System.Environment.GetEnvironmentVariable("CDBPF_Event_Time_Prefix_Path");
                    string event_dataversion = System.Environment.GetEnvironmentVariable("CDBPF_Event_DataVersion");
                    string event_dataversion_path = System.Environment.GetEnvironmentVariable("CDBPF_Event_DataVersion_Path");
                    string event_topic = System.Environment.GetEnvironmentVariable("CDBPF_Event_Topic");
                    string event_topic_path = System.Environment.GetEnvironmentVariable("CDBPF_Event_Topic_Path");

                    if(string.IsNullOrEmpty(config_file))
                        config_file = "CDBPF.configure.json";
                        
                    try
                    {
                        string content = string.Empty; 
                        content = GetContentFile(config_file, context);   
                        JObject config = JObject.Parse(content); 
                        if(config["CDBPF_Event_TopicEndpoint"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_TopicEndpoint"].ToString()))
                            event_topic_endpoint = config["CDBPF_Event_TopicEndpoint"].ToString();
                        if(config["CDBPF_Event_TopicKey"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_TopicKey"].ToString()))
                            event_topic_key = config["CDBPF_Event_TopicKey"].ToString();
                        if(config["CDBPF_Event_Subject_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Subject_Path"].ToString()))
                            event_subject = config["CDBPF_Event_Subject_Path"].ToString();
                        if(config["CDBPF_Event_Type"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Type"].ToString()))
                            event_type = config["CDBPF_Event_Type"].ToString();
                        if(config["CDBPF_Event_ID_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_ID_Path"].ToString()))
                            event_id = config["CDBPF_Event_ID_Path"].ToString();
                        if(config["CDBPF_Event_Type_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Type_Path"].ToString()))
                            event_type_path = config["CDBPF_Event_Type_Path"].ToString();
                        if(config["CDBPF_Event_Time_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Time_Path"].ToString()))
                            event_time_path = config["CDBPF_Event_Time_Path"].ToString();
                        if(config["CDBPF_Event_Time_Prefix"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Time_Prefix"].ToString()))
                            event_time_prefix = config["CDBPF_Event_Time_Prefix"].ToString();
                        if(config["CDBPF_Event_Time_Prefix_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Time_Prefix_Path"].ToString()))
                            event_time_prefix_path = config["CDBPF_Event_Time_Prefix_Path"].ToString();    
                        if(config["CDBPF_Event_DataVersion"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_DataVersion"].ToString()))
                            event_dataversion = config["CDBPF_Event_DataVersion"].ToString();    
                        if(config["CDBPF_Event_DataVersion_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_DataVersion_Path"].ToString()))
                            event_dataversion_path = config["CDBPF_Event_DataVersion_Path"].ToString();   
                        if(config["CDBPF_Event_Topic"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Topic"].ToString()))
                            event_topic = config["CDBPF_Event_Topic"].ToString();                       
                        if(config["CDBPF_Event_Topic_Path"] != null && !string.IsNullOrEmpty(config["CDBPF_Event_Topic_Path"].ToString()))
                            event_topic_path = config["CDBPF_Event_Topic_Path"].ToString();                       
                    }
                    catch { }
                       
                    string event_time = null;
                    if(!string.IsNullOrEmpty(event_time_path))
                        event_time = getValueFromJObject(json_data, event_time_path);

                     if(string.IsNullOrEmpty(event_time))
                        event_time = time_now_milisec;

                    if(string.IsNullOrEmpty(event_time_prefix))
                        event_time_prefix = getValueFromJObject(json_data, event_time_prefix_path);

                    if(!string.IsNullOrEmpty(event_time_prefix))
                        if(event_time.StartsWith(event_time_prefix))
                            event_time = event_time.Substring(event_time_prefix.Length);

                    if(string.IsNullOrEmpty(event_type))
                        event_type = getValueFromJObject(json_data, event_type_path);

                    if(string.IsNullOrEmpty(event_dataversion))
                        event_dataversion = getValueFromJObject(json_data, event_dataversion_path);

                    event_subject = getValueFromJObject(json_data, event_subject);
                    event_id = getValueFromJObject(json_data, event_id);

                    if(string.IsNullOrEmpty(event_subject))
                        event_subject = $"https://{System.Environment.GetEnvironmentVariable("WEBSITE_HOSTNAME")}/api/{context.FunctionName}";

                    if (string.IsNullOrEmpty(event_id) && (json_data["id"] != null && !string.IsNullOrEmpty(json_data["id"].ToString())))
                        event_id = json_data["id"].ToString();

                    if (string.IsNullOrEmpty(event_type))
                        event_type = "normal";

                    if(!string.IsNullOrEmpty(event_topic_path) && string.IsNullOrEmpty(event_topic))
                        event_topic = getValueFromJObject(json_data, event_topic_path);

                    StringBuilder st = new StringBuilder();
                    st.Append("[{ ");
                    st.Append($"\"subject\": \"{event_subject}\", ");
                    if (!string.IsNullOrEmpty(event_topic))
                        st.Append($"\"topic\": \"{event_topic}\", ");
                    st.Append($"\"eventType\": \"{event_type}\", ");
                    st.Append($"\"id\": \"{event_id}\", ");
                    st.Append($"\"eventTime\": \"{event_time}\", ");
                     st.Append($"\"dataVersion\":\"{event_dataversion}\", ");
                    st.Append($"\"data\": {json_data}");                   
                    st.Append(" }]");

log.LogInformation("Event Grid Event:");
log.LogInformation(st.ToString());


                    byte[] _data = Encoding.UTF8.GetBytes(st.ToString());

                    var httpWebRequest = (HttpWebRequest)WebRequest.Create(event_topic_endpoint);
                    httpWebRequest.ContentType = "application/json";
                    httpWebRequest.Method = "POST";
                    httpWebRequest.Headers.Add("aeg-sas-key", event_topic_key);
                    httpWebRequest.ContentLength = _data.Length;

                    using (Stream requestStream = httpWebRequest.GetRequestStream())
                    {
                        requestStream.Write(_data, 0, _data.Length);
                    }

                    try
                    {
                        var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();

                        using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                        {
                            string result = streamReader.ReadToEnd();

                            log.LogInformation("Status: 200");
                            log.LogInformation("Send an Event to Event Grid Topic success.");
                            log.LogInformation("");
                            log.LogInformation("......................");
                        }
                    }
                    catch (WebException ex)
                    {
                        JObject tmp = new JObject();
                        string result = string.Empty;
                        string erMsg = string.Empty;

                        using (var stream = ex.Response.GetResponseStream())
                        using (var reader = new StreamReader(stream))
                        {
                            result = reader.ReadToEnd();
                        }

                        log.LogError(result);
                        log.LogInformation("");
                        log.LogInformation("......................");

                        throw new Exception(result);
                    }
                }
            }
        }

        public static string getValueFromJObject(JObject obj, string path)
        {
            if (string.IsNullOrEmpty(path))
                return null;

            string ret = string.Empty;
            path = path.TrimStart('$');
            path = path.TrimStart('.', '/').Replace("/", ".");
            try
            {
                ret = obj.SelectToken(path).ToString();
            }
            catch { }
            return ret;
        }

        public static string GetContentFile(string file_path, ExecutionContext context)
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