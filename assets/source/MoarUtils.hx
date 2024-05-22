import funkin.backend.MusicBeatState;




class MoarUtils extends flixel.FlxBasic {

	public function get_innerData(xml:Xml) {
		var it = xml.iterator();
		if (!it.hasNext())
			throw " does not have data";
		var v = it.next();
		if (it.hasNext()) {
			var n = it.next();
			// handle <spaces>CDATA<spaces>
			if (v.nodeType == Xml.PCData && n.nodeType == Xml.CData && StringTools.trim(v.nodeValue) == "") {
				if (!it.hasNext())
					return n.nodeValue;
				var n2 = it.next();
				if (n2.nodeType == Xml.PCData && StringTools.trim(n2.nodeValue) == "" && !it.hasNext())
					return n.nodeValue;
			}
			throw " does not only have data";
		}
		if (v.nodeType != Xml.PCData && v.nodeType != Xml.CData)
			throw " does not have data";
		return v.nodeValue;
	}


}