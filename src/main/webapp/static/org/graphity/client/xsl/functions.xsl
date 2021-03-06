<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright (C) 2012 Martynas Jusevičius <martynas@graphity.org>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->
<!DOCTYPE xsl:stylesheet [
    <!ENTITY java "http://xml.apache.org/xalan/java/">
    <!ENTITY gc "http://client.graphity.org/ontology#">
    <!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    <!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
    <!ENTITY xsd "http://www.w3.org/2001/XMLSchema#">
    <!ENTITY sparql "http://www.w3.org/2005/sparql-results#">
    <!ENTITY dc "http://purl.org/dc/elements/1.1/">
    <!ENTITY dct "http://purl.org/dc/terms/">
    <!ENTITY foaf "http://xmlns.com/foaf/0.1/">
    <!ENTITY skos "http://www.w3.org/2004/02/skos/core#">
    <!ENTITY gr "http://purl.org/goodrelations/v1#">
    <!ENTITY list "http://jena.hpl.hp.com/ARQ/list#">
]>
<xsl:stylesheet version="2.0"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xhtml="http://www.w3.org/1999/xhtml"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:url="&java;java.net.URLDecoder"
xmlns:gc="&gc;"
xmlns:rdf="&rdf;"
xmlns:rdfs="&rdfs;"
xmlns:xsd="&xsd;"
xmlns:sparql="&sparql;"
xmlns:dc="&dc;"
xmlns:dct="&dct;"
xmlns:foaf="&foaf;"
xmlns:skos="&skos;"
xmlns:gr="&gr;"
xmlns:list="&list;"
exclude-result-prefixes="#all">

    <!-- http://xml.apache.org/xalan-j/extensions_xsltc.html#java_ext -->

    <xsl:key name="resources-by-subclass" match="*[@rdf:about] | *[@rdf:nodeID]" use="rdfs:subClassOf/@rdf:resource"/>
    <xsl:key name="resources-by-domain" match="*[@rdf:about] | *[@rdf:nodeID]" use="rdfs:domain/@rdf:resource"/>
    <xsl:key name="resources-by-range" match="*[@rdf:about] | *[@rdf:nodeID]" use="rdfs:range/@rdf:resource"/>
    <xsl:key name="resources-by-broader" match="*[@rdf:about] | *[@rdf:nodeID]" use="skos:broader/@rdf:resource"/>
    <xsl:key name="resources-by-narrower" match="*[@rdf:about] | *[@rdf:nodeID]" use="skos:narrower/@rdf:resource"/>

    <xsl:function name="gc:document-uri" as="xs:anyURI">
	<xsl:param name="uri" as="xs:anyURI"/>
	<xsl:choose>
	    <!-- strip trailing fragment identifier (#) -->
	    <xsl:when test="contains($uri, '#')">
		<xsl:sequence select="xs:anyURI(substring-before($uri, '#'))"/>
	    </xsl:when>
	    <xsl:otherwise>
		<xsl:sequence select="$uri"/>
	    </xsl:otherwise>
	</xsl:choose>
    </xsl:function>

    <xsl:function name="gc:fragment-id" as="xs:string?">
	<xsl:param name="uri" as="xs:anyURI"/>
	
	<xsl:sequence select="substring-after($uri, '#')"/>
    </xsl:function>

    <xsl:function name="gc:label" as="xs:string?">
	<xsl:param name="resource" as="node()"/>
	
	<xsl:apply-templates select="$resource" mode="gc:LabelMode"/>
    </xsl:function>

    <xsl:function name="rdfs:domain" as="attribute()*">
	<xsl:param name="property-uri" as="xs:anyURI+"/>
	<xsl:for-each select="$property-uri">
	    <xsl:for-each select="document(gc:document-uri($property-uri))">
		<xsl:sequence select="key('resources', $property-uri)/rdfs:domain/@rdf:resource"/>
	    </xsl:for-each>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="gc:inDomainOf" as="attribute()*">
	<xsl:param name="type-uri" as="xs:anyURI+"/>
	<xsl:for-each select="$type-uri">
	    <xsl:for-each select="document(gc:document-uri(.))">
		<xsl:sequence select="key('resources-by-domain', $type-uri)/@rdf:about"/>
	    </xsl:for-each>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="rdfs:range" as="attribute()*">
	<xsl:param name="property-uri" as="xs:anyURI+"/>
	<xsl:for-each select="$property-uri">
	    <xsl:for-each select="document(gc:document-uri($property-uri))">
		<xsl:sequence select="key('resources', $property-uri)/rdfs:range/@rdf:resource"/>
	    </xsl:for-each>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="rdfs:subClassOf" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:sequence select="rdfs:subClassOf($uri, document(gc:document-uri($uri)))"/>
    </xsl:function>

    <xsl:function name="rdfs:subClassOf" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:param name="document" as="document-node()"/>
	<xsl:for-each select="$document">
	    <xsl:sequence select="key('resources', $uri)/rdfs:subClassOf/@rdf:resource"/>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="gc:superClassOf" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:sequence select="gc:superClassOf($uri, document(gc:document-uri($uri)))"/>
    </xsl:function>

    <xsl:function name="gc:superClassOf" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:param name="document" as="document-node()"/>
	<xsl:for-each select="$document">
	    <xsl:sequence select="key('resources-by-subclass', $uri)/@rdf:about"/>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="skos:broader" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:sequence select="skos:broader($uri, document(gc:document-uri($uri)))"/>
    </xsl:function>

    <xsl:function name="skos:broader" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:param name="document" as="document-node()"/>
	<xsl:for-each select="$document">
	    <xsl:sequence select="key('resources', $uri)/skos:broader/@rdf:resource | key('resources-by-narrower', $uri)/@rdf:about"/>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="skos:narrower" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:sequence select="skos:narrower($uri, document(gc:document-uri($uri)))"/>
    </xsl:function>

    <xsl:function name="skos:narrower" as="attribute()*">
	<xsl:param name="uri" as="xs:anyURI+"/>
	<xsl:param name="document" as="document-node()"/>
	<xsl:for-each select="$document">
	    <xsl:sequence select="key('resources', $uri)/skos:narrower/@rdf:resource | key('resources-by-broader', $uri)/@rdf:about"/>
	</xsl:for-each>
    </xsl:function>

    <xsl:function name="list:member" as="node()*">
	<xsl:param name="list" as="node()?"/>
	<xsl:param name="document" as="document-node()"/>

	<xsl:if test="$list">
	    <xsl:sequence select="key('resources', $list/rdf:first/@rdf:resource, $document) | key('resources', $list/rdf:first/@rdf:nodeID, $document)"/>

	    <xsl:sequence select="list:member(key('resources', $list/rdf:rest/@rdf:resource, $document), $document) | list:member(key('resources', $list/rdf:rest/@rdf:nodeID, $document), $document)"/>
	</xsl:if>
    </xsl:function>

    <xsl:function name="gc:query-string" as="xs:string?">
	<xsl:param name="offset" as="xs:integer?"/>
	<xsl:param name="limit" as="xs:integer?"/>
	<xsl:param name="order-by" as="xs:string?"/>
	<xsl:param name="desc" as="xs:boolean?"/>
	<xsl:param name="mode" as="xs:anyURI?"/>
	
	<xsl:variable name="query-string">
	    <xsl:text>limit=</xsl:text><xsl:value-of select="$limit"/><xsl:text>&amp;</xsl:text>
	    <xsl:text>offset=</xsl:text><xsl:value-of select="$offset"/><xsl:text>&amp;</xsl:text>
	    <xsl:if test="$order-by">order-by=<xsl:value-of select="encode-for-uri($order-by)"/>&amp;</xsl:if>
	    <xsl:if test="$desc">desc=true&amp;</xsl:if>
	    <xsl:if test="$mode">mode=<xsl:value-of select="encode-for-uri($mode)"/>&amp;</xsl:if>
	</xsl:variable>
	
	<xsl:if test="string-length($query-string) &gt; 1">
	    <xsl:sequence select="concat('?', substring($query-string, 1, string-length($query-string) - 1))"/>
	</xsl:if>
    </xsl:function>

    <xsl:function name="gc:query-string" as="xs:string?">
	<xsl:param name="uri" as="xs:anyURI?"/>
	<xsl:param name="mode" as="xs:anyURI?"/>

	<xsl:variable name="query-string">
	    <xsl:if test="$uri">uri=<xsl:value-of select="encode-for-uri($uri)"/>&amp;</xsl:if>
	    <xsl:if test="$mode">mode=<xsl:value-of select="encode-for-uri($mode)"/>&amp;</xsl:if>
	</xsl:variable>
	
	<xsl:if test="string-length($query-string) &gt; 1">
	    <xsl:sequence select="concat('?', substring($query-string, 1, string-length($query-string) - 1))"/>
	</xsl:if>
    </xsl:function>

    <xsl:function name="gc:query-string" as="xs:string?">
	<xsl:param name="endpoint-uri" as="xs:anyURI?"/>
	<xsl:param name="query" as="xs:string?"/>
	<xsl:param name="accept" as="xs:string?"/>

	<xsl:variable name="query-string">
	    <xsl:if test="$endpoint-uri">endpoint-uri=<xsl:value-of select="encode-for-uri($endpoint-uri)"/>&amp;</xsl:if>
	    <xsl:if test="$query">query=<xsl:value-of select="encode-for-uri($query)"/>&amp;</xsl:if>
	    <xsl:if test="$accept">accept=<xsl:value-of select="encode-for-uri($accept)"/>&amp;</xsl:if>
	</xsl:variable>
	
	<xsl:if test="string-length($query-string) &gt; 1">
	    <xsl:sequence select="concat('?', substring($query-string, 1, string-length($query-string) - 1))"/>
	</xsl:if>
    </xsl:function>

</xsl:stylesheet>