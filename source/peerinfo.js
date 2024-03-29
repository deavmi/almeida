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


        /* Set the "well-formedness" alert */
        var wellFormednessAlert = document.getElementById("wellformedness-alert");
        var wellFormednessAlertStyle;

        if(status == "ok")
        {
            wellFormednessAlertStyle = "primary";
        }
        else if(status == "malformed")
        {
            wellFormednessAlertStyle = "warning";
        }
        else if(status == "timeout")
        {
            wellFormednessAlertStyle = "danger";
        }
        /* If there was a fetching error (TODO: Idk if an exception is thrown but I think so) */
        else
        {
            /* TODO: If exception then no need to do this HERE */
        }

        /* Set the style */
        wellFormednessAlert.setAttribute("class", "alert alert-"+wellFormednessAlertStyle);
        /* TODO: Set text */


        
       
        /* If wellformed */
        
            app.address = resp.response.address;
            app.domain = resp.response.domain;
            app.location = resp.response.location;
            app.name = resp.response.name;

            app.nodeinfo = resp.response.nodeinfo;
            app.contact = resp.response.contact;

            /* TODO: Set bubble here */
            console.log("WOOOPP!!");
        
        
        console.log("WOOOPP!!");
    

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