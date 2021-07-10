var app = new Vue(
	{
		el: "#render",
		data: {
			address: "<address>",
            domain: "<domain>",
            location: "<location>",
            name: "<name>",
            contact: "<contact>",
            nodeinfo: {},
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

    if ("location" in resp)
    {
        console.log("naaia");
    }

    if(resp != null)
    {
        /* Get the JSON */
        resp = await resp.json();

        /* Get status */
        var status = resp.status;

        /* If wellformed */
        if(status == "ok")
        {
            app.address = resp.address;
            app.domain = resp.domain;
            app.location = resp.location;
            app.name = resp.name;
            app.nodeinfo = resp.nodeinfo;
            app.contact = resp.contact;

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