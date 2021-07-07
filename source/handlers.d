module handlers;

import app;
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
	return d.getKeys();
}

void peerlist(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Fetch the peers list from Arceliar's node */
	string[] peers = getKeys();
	string[] names;


	ulong offset = to!(ulong)(request.query["offset"]);
	peers = peers[offset..offset+10];


	/* Fetch node names */
	Address testNode = parseAddress("201:6c56:f9d5:b7a5:8f42:b1ab:9e0e:5169", 9090);
	YggdrasilPeer yggPeer = new YggdrasilPeer(testNode);
	foreach(string peer; peers)
	{
		/* Fetch the node */
		YggdrasilNode yggNode = yggPeer.fetchNode(peer);

		/* Fetch the NodeInfo */
		NodeInfo nodeInfo = yggNode.getNodeInfo();

		/* Get the name */
		string name = nodeInfo.getName();
		names~=name;
	}
	
	/* Render the template */
	response.render!("peerlist.dt", peers, names);
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

void buildinfo(HTTPServerRequest request, HTTPServerResponse response)
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
	JSONValue nodeinfo = nodeInfo.getFullJSON();

	string name = nodeinfo["buildname"].str();
	string platform = nodeinfo["buildplatform"].str();
	string arch = nodeinfo["buildarch"].str();
	string _version = nodeinfo["buildversion"].str();
	
	//response.writeBody(to!(string)(request));
	
	
	/* Render the template */
	response.render!("buildinfo.dt", key, name, platform, arch, _version);
}

void about(HTTPServerRequest request, HTTPServerResponse response)
{
	/* Render the template */
	response.render!("about.dt");
}

void error(HTTPServerRequest request, HTTPServerResponse response, HTTPServerErrorInfo error)
{
	/* Render the template */
	response.render!("error.dt", error);
}

