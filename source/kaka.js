var app = new Vue(
	{
		el: "#render",
		data: {
			nodename: "deavmi.crxn",
			poes: "deavmi.crxn",
			nodes: ["poes"],
			platforms: [
				{ name: ' ', count: 0},
			],
			archs: [
				{ name: ' ', count: 0},
			],
			versions: [
				{ name: ' ', count: 0},
			],
		},
		methods: {
			refresh: async function(event) {
				this.nodename = "d"
				resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/")
				resp = await resp.json();
				this.nodename = resp["name"];
				this.nodes = this.nodename;

				resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/builddb")
				resp = await resp.json();
				this.platforms = resp.platforms;
				this.archs = resp.archs;
				this.versions = resp.versions;

				console.log("fddf");
			
			

				
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

						resp = await fetch("http://[201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169]:9091/api/")
						resp = await resp.json();
						this.archCount = resp["name"]+this.archCount;
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

async function fetchCyle()
{
	app.nodename = "d"
				resp = await fetch("/api/")
				resp = await resp.json();
				app.nodename = resp["name"];
				app.nodes = app.nodename;

				resp = await fetch("/api/builddb")
				resp = await resp.json();
				app.platforms = resp.platforms;
				app.archs = resp.archs;
				app.versions = resp.versions;
				console.log("kak");
			
}

	// Delay the execution of this function in the event loop
	setInterval(fetchCyle, 500);
	
