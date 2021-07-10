var app = new Vue(
	{
		el: "#render",
		data: {
			architecture: "<address>",
            buildname: "<domain>",
            version: "<location>",
            platform: "<name>",
		},
		methods: {
			refresh: async function(event) {
				updateData();
			}
		}
	}
)

async function updateData()
{
	resp = await fetch("/api/peerinfo?key="+key)

    if(resp != null)
    {
        /* Get the JSON */
        resp = await resp.json();

        /* Get status */
        var status = resp.status;

        /* If wellformed */
        if(status == "ok")
        {
            app.address = resp.response.address;
            app.domain = resp.response.domain;
            app.location = resp.response.location;
            app.name = resp.response.name;
            app.nodeinfo = resp.response.nodeinfo;
            app.contact = resp.response.contact;

            /* TODO: Set bubble here */
        }
        /* If malformed */
        else
        {
            /* TODO: Set bubble here */
        }
        
    
    

        /* TODO: Set last updated bubble */
    }
    else
    {
        /* TODO: Set a bubble here */
        app.address = "Failed to fetch";
        app.domain = "Failed to fetch";
        app.location = "Failed to fetch";
        app.name = "Failed to fetch";
        app.nodeinfo = "Failed to fetch";
        app.contact = "Failed to fetch";
    }
	
}

// Add this to the event loop with a 500millisecond re-run interval
setInterval(updateData, 500);