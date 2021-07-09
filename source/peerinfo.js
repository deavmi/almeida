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
				resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/nodeinfo?key="+key)
				resp = await resp.json();
				this.data = resp;
			}
		}
	}
	)


/**
* Architecture component (archName)
*
* Given archName it will fetch its count
*/
Vue.component('archBlock', {
	props: ['archName'],
	data: function () {
		return {
			archCount: 0
		}
	},
	methods: {
		update: async function(event) {
            updateData();
		}
	},
	template: '<button v-on:click="update">{{archCount}}</bruh>'
  		
})


async function apiTest()
{
	resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/")
	resp = await resp.json();
	return resp.name;
}

async function updateData()
{
	resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/")
						resp = await resp.json();
						this.archCount = resp["name"]+this.archCount;
			
}

	// Delay the execution of this function in the event loop
	setInterval(updateData, 500);
	
