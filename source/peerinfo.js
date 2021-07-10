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
    if(resp != null)
    {
        resp = await resp.json();
        console.log(resp.name);
        app.address = resp.address;
        app.domain = resp.domain;
        app.location = resp.location;
        app.name = resp.name;
        app.nodeinfo = resp.nodeinfo;
        app.contact = resp.contact;

        /* TODO: Set last updated bubble */
    }
    else
    {
        /* TODO: Set a bubble here */
    }
	
}

// Add this to the event loop with a 500millisecond re-run interval
setInterval(updateData, 500);