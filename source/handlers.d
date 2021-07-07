module handlers;

import vibe.vibe;
import libyggdrasil;
import std.net.curl;
import std.json;
import std.stdio;
import std.socket;

void home(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Render the template */
	response.render!("index.dt");
}


private string[] getKeys()
{
	string url = "http://[21e:e795:8e82:a9e2:ff48:952d:55f2:f0bb]/static/current";
	string[] keys;
	
	import std.net.curl;
	string k = cast(string)get(url);

	//writeln(k);

	JSONValue json = parseJSON(k);
	json = json["yggnodes"];

	keys = json.object().keys;
//	writeln(keys);

	return keys;
}

void peerlist(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Fetch the peers list from Arceliar's node */
	string[] peers = getKeys();
	
	/* Render the template */
	response.render!("peerlist.dt", peers);
}

void peerinfo(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Fetch the key */
	/* TODO: Validate the key */
	string key = request.query["key"];

	Address testNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	YggdrasilPeer yggPeer = new YggdrasilPeer(testNode);

	/* Fetch the node */
	YggdrasilNode yggNode = yggPeer.fetchNode(key);

	/* Fetch the NodeInfo */
	NodeInfo nodeInfo = yggNode.getNodeInfo();
	
	/* TODO: Fix up yggdraisl library for this */
	string ip = nodeInfo.getAddress();
	string name = nodeInfo.getName();
	string group = nodeInfo.getGroupName();
	string country = nodeInfo.getCountry();
	string operator = nodeInfo.getOperatorBlock().toPrettyString();

	string nodeInfoJSON = nodeInfo.getFullJSON().toPrettyString();
	
	writeln(request);
	//response.writeBody(to!(string)(request));
	
	
	/* Render the template */
	response.render!("peerinfo.dt", key, ip, name, group, operator, country, nodeInfoJSON);
}