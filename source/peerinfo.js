var app = new Vue(
	{
		el: "#render",
		data: {
			address: "<address>",
            domain: "<domain>",
            location: "<location>",
            name: "<name>",
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
	resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/peerinfo?key="+key)
    if(resp != null)
    {
        resp = await resp.json();
        console.log(resp.name);
        app.address = resp.address;
        app.domain = resp.domain;
        app.location = resp.location;
        app.name = resp.name;

        /* TODO: Set last updated bubble */
    }
    else
    {
        /* TODO: Set a bubble here */
    }
	
}

// Add this to the event loop with a 500millisecond re-run interval
setInterval(updateData, 500);