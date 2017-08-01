<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <sch:title>hsg-project oXygen Project file schematron</sch:title>
    <sch:pattern id="uri-checks">
        <sch:title>URI checks</sch:title>
        <sch:rule context="field[@name=('uri', 'inputXSLURL')]">
            <sch:assert test="starts-with(String, '${pdu}')">URIs should be relative to the project directory, should start with '${pdu}'</sch:assert>
        </sch:rule>
    </sch:pattern>
</sch:schema>