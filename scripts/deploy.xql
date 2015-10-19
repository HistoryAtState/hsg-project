xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console";

declare namespace expath="http://expath.org/ns/pkg";

declare variable $temp external;
declare variable $xar external;

declare variable $repo := 
    "http://demo.exist-db.org/exist/apps/public-repo/modules/find.xql";

(:~
 : Uninstall given package if it is installed.
 : 
 : @return true if the package could be removed, false otherwise
 :)
declare function local:remove($package-url as xs:string) as xs:boolean {
    if ($package-url = repo:list()) then
        let $undeploy := repo:undeploy($package-url)
        let $remove := repo:remove($package-url)
        let $log := console:log("Removing package " || $package-url)
        return
            $remove
    else
        false()
};

declare %private function local:entry-filter($path as xs:anyURI, $type as xs:string, $param as item()*) as xs:boolean
{
	$path = "expath-pkg.xml"
};

declare %private function local:entry-data($path as xs:anyURI, $type as xs:string, $data as item()?, $param as item()*) as item()?
{
    <entry>
        <path>{$path}</path>
    	<type>{$type}</type>
    	<data>{$data}</data>
    </entry>
};

let $xarPath := $temp || "/" || $xar
let $meta :=
    try {
        compression:unzip(
            util:binary-doc($xarPath), local:entry-filter#3, 
            (),  local:entry-data#4, ()
        )
    } catch * {
        error(xs:QName("local:xar-unpack-error"), 
            "Failed to unpack archive")
    }
let $package := $meta//expath:package/string(@name)
let $log := console:log($package)
let $removed := local:remove($package)
return
    (
        console:log("Installing package " || $package),
        repo:install-and-deploy-from-db($temp || "/" || $xar, $repo)
    )