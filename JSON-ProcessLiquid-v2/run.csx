#r "Newtonsoft.Json"
#r "System.Configuration"
#r "DotLiquid.dll"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.IO;
using System;
using DotLiquid;
using System.Configuration; 

public static async Task<IActionResult> Run(HttpRequest req, ILogger log, ExecutionContext context)
{
    
            FuncParam _req = new FuncParam();
            string resultText = string.Empty;
            JObject result = new JObject();

            try
            {
                dynamic data = JsonConvert.DeserializeObject(await new StreamReader(req.Body).ReadToEndAsync());
                _req = JsonConvert.DeserializeObject<FuncParam>(JsonConvert.SerializeObject(PrepareParameter(data, context, req)));

                string template = GetTemplate(_req.liquidTemplate, _req.liquidTemplate_lang, context);

                if (string.IsNullOrEmpty(template))
                    throw new Exception($"Could not find {_P.liquidTemplate}.");

                JObject _data = new JObject();

                try
                {
                    if (_req.data != null && !string.IsNullOrEmpty(_req.data.ToString()))
                        _data = JsonConvert.DeserializeObject<JObject>(_req.data.ToString(), new JsonSerializerSettings() { DateParseHandling = DateParseHandling.None });
                }
                catch
                {
                    throw new Exception($"{_P.data} is not JSON format.");
                }

                Template _template = Template.Parse(template);

                string tmp_result = string.Empty;

                if (_data.HasValues)
                {
                    Dictionary<string, object> dic = deserializeToDictionary(_data.ToString());//JsonConvert.DeserializeObject<Dictionary<string, object>>(_data.ToString());
                    tmp_result = _template.Render(Hash.FromDictionary(dic));
                }
                else
                {
                    tmp_result = _template.Render();
                }

                log.LogInformation(tmp_result);

                if (!string.IsNullOrEmpty(tmp_result))
                {
                    string otype = string.IsNullOrEmpty(_req.outputType)? string.Empty : _req.outputType.ToLower();

                    switch (otype)
                    {
                        case "text":
                            resultText = tmp_result;
                            break;
                        case "json":
                        default:
                            try
                            {
                                result = JObject.Parse(tmp_result);
                            }
                            catch
                            {
                                resultText = tmp_result;
                            }
                            break;
                    }
                }
                
                return (ActionResult)new OkObjectResult(BuildResponseMessage(result, resultText, _req));
            }
            catch (Exception ex)
            {
                log.LogError(ex.Message);
                return (ActionResult)new BadRequestObjectResult(BuildResponseMessage(result, resultText, _req));
            }
        }

        public static Dictionary<string, object> deserializeToDictionary(string jo)
        {
            var values = JsonConvert.DeserializeObject<Dictionary<string, object>>(jo);
            var values2 = new Dictionary<string, object>();
            foreach (KeyValuePair<string, object> d in values)
            {
                // if (d.Value.GetType().FullName.Contains("Newtonsoft.Json.Linq.JObject"))
                if (d.Value is JObject)
                {
                    values2.Add(d.Key, deserializeToDictionary(d.Value.ToString()));
                }
                else if (d.Value is JArray)
                {
                    values2.Add(d.Key, JsonConvert.DeserializeObject<Object[]>(d.Value.ToString()));
                }
                else
                {
                    values2.Add(d.Key, d.Value);
                }
            }
            return values2;
        }

        public class FuncParam
        {
            public string Configuration { get; set; }
            public string Configuration_lang { get; set; }
            public string liquidTemplate { get; set; }
            public string liquidTemplate_lang { get; set; }
            public string outputType { get; set; }
            public string lang { get; set; }
            public object data { get; set; }
        }

        public static class _P
        {
            public static string Configuration = "Configuration";
            public static string Configuration_lang = "Configuration_lang";
            public static string Configuration_SettingName = "Configuration_SettingName";
            public const string data = "data";
            public const string data_SettingName = "data_SettingName";
            public const string liquidTemplate = "liquidTemplate";
            public const string liquidTemplate_lang = "liquidTemplate_lang";
            public const string liquidTemplate_SettingName = "liquidTemplate_SettingName";
            public const string outputType = "outputType";
            public const string outputType_SettingName = "outputType_SettingName";
            public const string lang = "lang";
            public const string lang_SettingName = "lang_SettingName";
        }

        #region -- Functions --
        public static JObject BuildResponseMessage(JObject result, string resultText, FuncParam _req)
        {
            JObject obj = new JObject();
            obj.Add("result", result == null || !result.HasValues ? null : result);
            obj.Add("resultText", !string.IsNullOrEmpty(resultText)? resultText : null);
            

            if (!string.IsNullOrEmpty(_req.liquidTemplate_lang))
                _req.liquidTemplate = _req.liquidTemplate_lang;

            if (!string.IsNullOrEmpty(_req.Configuration_lang))
                _req.Configuration = _req.Configuration_lang;

            obj.Add("liquidInfo", JObject.Parse(JsonConvert.SerializeObject(_req)));
            (obj["liquidInfo"] as JObject).Remove(_P.liquidTemplate_lang);
            (obj["liquidInfo"] as JObject).Remove(_P.Configuration_lang);

            return obj;
        }

        public static JObject GetConfigurationFile(JObject obj, ExecutionContext context)
        {
            JObject result = new JObject();

            try
            {
                string content = string.Empty;

                if (obj[_P.Configuration_lang] != null && !string.IsNullOrEmpty(obj[_P.Configuration_lang].ToString()))
                {
                    content = GetContentFile(obj[_P.Configuration_lang].ToString(), context);
                }
                else
                {
                    content = GetContentFile(obj[_P.Configuration].ToString(), context);
                }

                result = JObject.Parse(content);
            }
            catch { }

            return result;
        }

        public static string GetParameterInApplicationSetting(string key)
        {
            string result = null;
            try
            {
                result = System.Environment.GetEnvironmentVariable(key);
            }
            catch { }

            return result;
        }

        public static string GetParameterInConnectionString(string key)
        {
            string result = null;
            try
            {
                result = ConfigurationManager.ConnectionStrings[key].ConnectionString;
            }
            catch { }

            return result;
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

        public static JObject PrepareParameter(JObject direct_param, ExecutionContext context, HttpRequest req)
        {
            JObject obj = new JObject();
            JObject _default = new JObject();

            string[] keys = new string[]
            {
                _P.data,
                _P.data_SettingName,
                _P.liquidTemplate,
                _P.liquidTemplate_lang,
                _P.liquidTemplate_SettingName,
                _P.outputType,
                _P.outputType_SettingName,
                _P.lang,
                _P.lang_SettingName,
                _P.Configuration,
                _P.Configuration_lang,
                _P.Configuration_SettingName
            };

            string[] keys_msg = new string[] { };
            string[] keys_lang = new string[] { _P.liquidTemplate_lang };

            Dictionary<string, bool> dicApplyConfig = new Dictionary<string, bool>();
            JObject config = new JObject();
            bool hasLang = false;

            try
            {
                // --------- Request Body -------------
                foreach (string key in keys)
                {
                    obj.Add(key, null);
                    _default.Add(key, null);
                }

                if (direct_param != null)
                {
                    foreach (KeyValuePair<string, JToken> t in direct_param)
                    {
                        if(obj[t.Key] != null)
                            obj[t.Key] = t.Value;
                    }
                }
                if (string.IsNullOrEmpty(obj[_P.Configuration_SettingName].ToString()))
                    obj[_P.Configuration_SettingName] = "DotLiq_DEFAULT_Configuration";

                obj = GetValueFromAppSetting(obj, keys);
                obj = GetValueFromAppSetting(obj, keys_msg);

                if (obj[_P.lang] != null && !string.IsNullOrEmpty(obj[_P.lang].ToString()))
                {
                    obj = ApplyLanguage(obj, new string[] { _P.Configuration_lang }, null, false);
                    hasLang = true;
                }
                if (obj[_P.Configuration] == null || string.IsNullOrEmpty(obj[_P.Configuration].ToString()))
                {
                    obj[_P.Configuration] = "DotLiq.configure.json";
                }
                config = GetConfigurationFile(obj, context);
                config = GetValueFromAppSetting(config, keys);
                config = GetValueFromAppSetting(config, keys_msg);

                if (!hasLang)
                {
                    if (config[_P.lang] != null && !string.IsNullOrEmpty(config[_P.lang].ToString()))
                    {
                        hasLang = true;
                        obj = ParameterMapping(obj, config, keys, keys_msg, out dicApplyConfig, true);
                    }
                }
                else
                {
                    obj = ParameterMapping(obj, config, keys, keys_msg, out dicApplyConfig, true);
                }

                _default[_P.lang_SettingName] = "DotLiq_DEFAULT_lang";
                _default[_P.data_SettingName] = "DotLiq_DEFAULT_data";
                _default[_P.liquidTemplate_SettingName] = "DotLiq_DEFAULT_liquidTemplate";
                _default[_P.outputType_SettingName] = "DotLiq_DEFAULT_outputType";

                _default = GetValueFromAppSetting(_default, keys);
                _default = GetValueFromAppSetting(_default, keys_msg);

                obj = GetValueFromAppSetting(obj, keys);
                _default = GetValueFromAppSetting(_default, keys);

                if (string.IsNullOrEmpty(obj[_P.lang].ToString()))
                    if(!string.IsNullOrEmpty(_default[_P.lang].ToString()))
                        obj[_P.lang] = _default[_P.lang];

                if (!hasLang)
                {
                    if (_default[_P.lang] != null && !string.IsNullOrEmpty(_default[_P.lang].ToString()))
                    {
                        obj[_P.lang] = _default[_P.lang];
                        obj = ApplyLanguage(obj, new string[] { _P.Configuration_lang }, null, false);

                        config = new JObject();
                        config = GetConfigurationFile(obj, context);
                        config = GetValueFromAppSetting(config, keys);
                        config = GetValueFromAppSetting(config, keys_msg);
                        obj = ParameterMapping(obj, config, keys, keys_msg, out dicApplyConfig, true);
                        hasLang = true;
                    }
                    else
                    {
                        obj = ParameterMapping(obj, config, keys, keys_msg, out dicApplyConfig, true);
                    }
                }

                obj = ApplyLanguage(obj, keys_lang, dicApplyConfig, true);
            }
            catch { }

            return obj;
        }

        public static JObject GetValueFromAppSetting(JObject obj, string[] keys)
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

        public static JObject ParameterMapping(JObject source1, JObject source2, string[] keys, string[] keys_msg, out Dictionary<string, bool> dicApplyConfig, bool isApplyConfig)
        {
            dicApplyConfig = new Dictionary<string, bool>();

            foreach (string k in keys)
            {
                if (!k.Contains($"_{_P.lang}") && source1[$"{k}_{_P.lang}"] != null)
                {
                    if (string.IsNullOrEmpty(source1[k].ToString()))
                    {
                        if (!string.IsNullOrEmpty(source2[k].ToString()))
                        {
                            source1[k] = source2[k];
                            if (isApplyConfig)
                                dicApplyConfig.Add($"{k}_{_P.lang}", true);
                        }
                    }
                }
                else if (k.Contains($"_{_P.lang}")) { }
                else
                {
                    if (string.IsNullOrEmpty(source1[k].ToString()))
                        source1[k] = source2[k];
                }
            }

            if (!HasMessageValue(source1, keys_msg))
            {
                foreach (string k in keys_msg)
                {
                    if (!string.IsNullOrEmpty(source2[k].ToString()))
                    {
                        source1[k] = source2[k];

                        if (source1[$"{k}_{_P.lang}"] != null && isApplyConfig)
                            dicApplyConfig.Add($"{k}_{_P.lang}", true);
                    }
                }
            }

            return source1;
        }

        public static bool HasMessageValue(JObject source, string[] keys)
        {
            bool result = false;

            if (source != null)
            {
                foreach (string t in keys)
                {
                    if (source[t] != null && !string.IsNullOrEmpty(source[t].ToString()) && !t.EndsWith("_SettingName"))
                    {
                        result = true;
                        break;
                    }
                }
            }

            return result;
        }

        public static JObject ApplyLanguage(JObject obj, string[] keys, Dictionary<string, bool> dicApplyConfig, bool isApplyFull)
        {
            JObject output = obj;

            if (obj != null)
            {
                if (obj[_P.lang] != null && !string.IsNullOrEmpty(obj[_P.lang].ToString()))
                {
                    string lang = obj[_P.lang].ToString();

                    foreach (string key in keys)
                    {
                        string main_key = key.Replace($"_{_P.lang}", string.Empty);
                        string main_param = obj[main_key] == null ? null : obj[main_key].ToString();
                        bool isConvert = false;

                        if (!string.IsNullOrEmpty(main_param))
                        {
                            if (main_param.Contains("\\"))
                            {
                                main_param = main_param.Replace("\\", "/");
                                isConvert = true;
                            }

                            //Case: ../aaaa/aaa.aaa
                            int index_dot = main_param.LastIndexOf(".");
                            int index_slash = main_param.LastIndexOf("/");

                            if (index_dot > 0 && index_dot > index_slash)
                            {
                                string prefix = main_param.Substring(0, index_dot);
                                string suffix = main_param.Substring(index_dot);
                                main_param = $"{prefix}_{lang}{suffix}";

                                bool isSkip = false;


                                if (dicApplyConfig != null && isApplyFull)
                                {
                                    foreach (KeyValuePair<string, bool> a in dicApplyConfig)
                                    {
                                        if (key.Equals(a.Key))
                                        {
                                            isSkip = true;
                                            break;
                                        }
                                    }
                                }

                                if (!isSkip)
                                    output[key] = isConvert ? main_param.Replace("/", "\\") : main_param;
                            }
                            else
                            {
                                //Case: ../aaaaa/aaaa
                                string tmp = main_param + $"_{lang}";

                                bool isSkip = false;

                                if (dicApplyConfig != null && isApplyFull)
                                {
                                    foreach (KeyValuePair<string, bool> a in dicApplyConfig)
                                    {
                                        if (key.Equals(a.Key))
                                        {
                                            isSkip = true;
                                            break;
                                        }
                                    }
                                }

                                if (!isSkip)
                                    output[key] = isConvert ? tmp.Replace("/", "\\") : tmp;
                            }
                        }
                    }

                }
            }

            return output;
        }

        public static string GetTemplate(string filepath, string filepath_lang, ExecutionContext context)
        {
            string result = string.Empty;

            try
            {
                if (!string.IsNullOrEmpty(filepath_lang))
                    result = GetContentFile(filepath_lang, context);
                else
                    result = GetContentFile(filepath, context);
            }
            catch { }

            return result;
        }
        #endregion