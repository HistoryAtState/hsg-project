xquery version "3.0";

import module namespace console="http://exist-db.org/xquery/console";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";
import module namespace repo="http://exist-db.org/xquery/repo";

declare namespace expath="http://expath.org/ns/pkg";

(: functions from replication.xql are pasted in below, since xdb:query can't import modules that aren't on the remote server :)
declare namespace ru="http://exist-db.org/xquery/replication-util";

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
	$path = ("expath-pkg.xml", "repo.xml")
};

declare %private function local:entry-data($path as xs:anyURI, $type as xs:string, $data as item()?, $param as item()*) as item()?
{
    <entry>
        <path>{$path}</path>
    	<type>{$type}</type>
    	<data>{$data}</data>
    </entry>
};

declare variable $ru:sync-metadata :=
    let $tryImport :=
        try {
            util:import-module(xs:anyURI("http://exist-db.org/xquery/replication"), "replication",
                xs:anyURI("java:org.exist.jms.xquery.ReplicationModule")),
            true()
        } catch * {
            false()
        }
    return
        if ($tryImport) then
            function-lookup(xs:QName("replication:sync-metadata"), 1)
        else
            ()
;

declare function ru:sync($root as xs:anyURI, $delay as xs:long) {
    util:wait($delay),
    ru:sync($root)
};

declare function ru:sync($root as xs:anyURI) {
    if (exists($ru:sync-metadata)) then
        dbutil:scan($root, function($collection, $resource) {
            if ($resource) then
                $ru:sync-metadata($resource)
            else if ($collection != $root) then
                $ru:sync-metadata($collection)
            else
                ()
        })
    else
        ()
};

let $xarPath := $temp || "/" || $xar
let $check-if-xar-exists := 
    if (util:binary-doc-available($xarPath)) then 
        ()
    else
        error(xs:QName("local:xar-missing-error"), "Failed to locate xar: " || $xarPath)
let $meta :=
    try {
        compression:unzip(
            util:binary-doc($xarPath), 
            local:entry-filter#3, 
            (),
            local:entry-data#4,
            ()
        )
    } catch * {
        error(xs:QName("local:xar-unpack-error"), "Failed to unpack archive: " || $err:description || ": " || $exerr:xquery-stack-trace)
    }
let $package := $meta//expath:package/@name/string()
let $target := $meta//repo:target
let $remove := 
    (
        console:log("Removing any previous installation of package " || $package),
        local:remove($package)
    )
return
    (
        console:log("Installing package " || $package),
        repo:install-and-deploy-from-db($xarPath, $repo),
        ru:sync(xs:anyURI("/db/apps/" || $target), 3000)
    )