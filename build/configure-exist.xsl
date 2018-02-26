<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="target" select="'development'"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="builtin-modules">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:comment>Modules enabled for hsg</xsl:comment>
            <module uri="http://exist-db.org/xquery/cache" class="org.exist.xquery.modules.cache.CacheModule" />
        </xsl:copy>        
    </xsl:template>

    <xsl:template match="serializer">
        <xsl:comment>indent=no set for hsg</xsl:comment>
        <xsl:copy>
            <xsl:apply-templates select="@* except @indent"/>
            <xsl:attribute name="indent">no</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>        
    </xsl:template>

    <xsl:template match="scheduler">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:choose>
                <xsl:when test="$target = 'production'">
                    <xsl:comment>Jobs enabled for hsg production</xsl:comment>
                    <job type="user" xquery="/db/apps/hsg-shell/modules/rebuild-dates-sort-index.xql" period="600000" unschedule-on-exception="false"/>
                    <job xquery="/db/apps/twitter/jobs/download-recent-twitter-posts.xq" period="600000"/>
                </xsl:when>
                <xsl:when test="$target = 'development'">
                    <xsl:comment>Jobs enabled for hsg development</xsl:comment>
                    <job type="user" xquery="/db/apps/hsg-shell/modules/rebuild-dates-sort-index.xql" period="600000" unschedule-on-exception="false"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:copy>        
    </xsl:template>

</xsl:stylesheet>