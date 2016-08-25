xquery version "3.1";

module namespace ru="http://exist-db.org/xquery/replication-util";

import module namespace dbutil="http://exist-db.org/xquery/dbutil";

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