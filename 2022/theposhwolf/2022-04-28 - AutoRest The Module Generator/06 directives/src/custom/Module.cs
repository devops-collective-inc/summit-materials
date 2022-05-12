namespace RunwaySdk.PowerShell
{
    using Runtime;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Threading;
    using System.Threading.Tasks;


    /// <summary>A class that contains the module-common code and data.</summary>
    /// <notes>
    /// This class is where you can add things to modify the module.
    /// As long as it's in the 'private/custom' folder, it won't get deleted
    /// when you use --clear-output-folder in autorest.
    /// </notes>
    public partial class Module
    {
        partial void CustomInit()
        {
            // we need to add a step at the end of the pipeline 
            // to attach the API key 

            // once for the regular pipeline
            this._pipeline.Append(AddSessionToken);

            // once for the pipeline that supports a proxy
            this._pipelineWithProxy.Append(AddSessionToken);
        }

        protected async Task<HttpResponseMessage> AddSessionToken(HttpRequestMessage request, IEventListener callback, ISendAsync next)
        {
            // does the request already have an authorization header? remove it
            if (request.Headers.Contains("Authorization")) request.Headers.Remove("Authorization");

            // add in the auth header
            request.Headers.Add("Authorization", "Session " + System.Environment.GetEnvironmentVariable("RunwaySessionToken"));

            // let it go on.
            return await next.SendAsync(request, callback);
        }
    }
}