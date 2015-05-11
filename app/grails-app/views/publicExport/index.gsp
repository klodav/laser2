<!doctype html>

<%@ page import="java.text.SimpleDateFormat"%>
<%
  def addFacet = { params, facet, val ->
    def newparams = [:]
    newparams.putAll(params)
    def current = newparams[facet]
    if ( current == null ) {
      newparams[facet] = val
    }
    else if ( current instanceof String[] ) {
      newparams.remove(current)
      newparams[facet] = current as List
      newparams[facet].add(val);
    }
    else {
      newparams[facet] = [ current, val ]
    }
    newparams
  }

  def removeFacet = { params, facet, val ->
    def newparams = [:]
    newparams.putAll(params)
    def current = newparams[facet]
    if ( current == null ) {
    }
    else if ( current instanceof String[] ) {
      newparams.remove(current)
      newparams[facet] = current as List
      newparams[facet].remove(val);
    }
    else if ( current?.equals(val.toString()) ) {
      newparams.remove(facet)
    }
    newparams
  }

  def dateFormater = new SimpleDateFormat("yy-MM-dd'T'HH:mm:ss.SSS'Z'")
%>

<html>

  <head>
    <meta name="layout" content="pubbootstrap"/>
    <title>KB+ Data import explorer</title>
  </head>


  <body class="public">

  <g:render template="public_navbar" contextPath="/templates" model="['active': 'publicExport']"/>


  <div class="container">
      <h1>Exports</h1>
    </div>

    <div class="container">
      <div class="row">
        <div class="span12">

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:vcard="http://www.w3.org/2001/vcard-rdf/3.0#">
 <a rel="license"
    href="http://creativecommons.org/publicdomain/zero/1.0/">
   <img src="http://i.creativecommons.org/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
 </a>
 <br />
 To the extent possible under law,
 <a rel="dct:publisher"
    href="http://www.kbplus.ac.uk/exports">
   <span property="dct:title">JISC Collections</span></a>
 has waived all copyright and related or neighboring rights to
 <span property="dct:title">KBPlus Public Exports</span>.
This work is published from:
<span property="vcard:Country" datatype="dct:ISO3166"
     content="GB" about="www.kbplus.ac.uk/exports">
 United Kingdom</span>.
</p>

        </div>
      </div>
    </div>

    <div class="container">
      <div class="row">
        <div class="span12">
          <div class="well">
            <h4>Cufts style index of subscriptions offered</h4>
            <p>
              Use the contents of this URI to drive a full crawl of the KB+ subscriptions offered data. Each row gives an identifier that can be used to
              construct individual subscription requests.
            </p>
            <g:link action="idx" params="${[format:'csv']}">Simple CSV</g:link><br/>
            <g:link action="idx" params="${[format:'xml']}">XML</g:link><br/>
            <g:link action="idx" params="${[format:'json']}">JSON</g:link><br/>
          </div>
        </div>
      </div>
    </div>




    <div class="container">
      <g:form action="index" method="get" params="${params}">
      <input type="hidden" name="offset" value="${params.offset}"/>

      <div class="row">
        <div class="span12">
          <div class="well form-horizontal">
            Package Name: <input name="q" placeholder="Add &quot;&quot; for exact match" value="${params.q}"/>
            Sort: <select name="sort">
                    <option ${params.sort=='sortname' ? 'selected' : ''} value="sortname">Package Name</option>
                    <option ${params.sort=='_score' ? 'selected' : ''} value="_score">Score</option>
                    <option ${params.sort=='lastModified' ? 'selected' : ''} value="lastModified">Last Modified</option>
                  </select>
            Order: <select name="order" value="${params.order}">
                    <option ${params.order=='asc' ? 'selected' : ''} value="asc">Ascending</option>
                    <option ${params.order=='desc' ? 'selected' : ''} value="desc">Descending</option>
                  </select>
            <button type="submit" name="search" value="yes">Search</button>
          </div>
        </div>
      </div>
      </g:form>

      <p>
          <g:each in="${['type','endYear','startYear','consortiaName','cpname']}" var="facet">
            <g:each in="${params.list(facet)}" var="fv">
              <span class="badge alert-info">${facet}:${fv} &nbsp; <g:link controller="${controller}" action="index" params="${removeFacet(params,facet,fv)}"><i class="icon-remove icon-white"></i></g:link></span>
            </g:each>
          </g:each>
        </p>

      <div class="row">

  
        <div class="facetFilter span2">
          <g:each in="${facets}" var="facet">
            <g:if test="${facet.key != 'type'}">
            <div class="panel panel-default">
              <div class="panel-heading">
                <h5><g:message code="facet.so.${facet.key}" default="${facet.key}" /></h5>
              </div>
              <div class="panel-body">
                <ul>
                  <g:each in="${facet.value.sort{it.display}}" var="v">
                    <li>
                      <g:set var="fname" value="facet:${facet.key+':'+v.term}"/>
 
                      <g:if test="${params.list(facet.key).contains(v.term.toString())}">
                        ${v.display} (${v.count})
                      </g:if>
                      <g:else>
                        <g:link controller="${controller}" action="${action}" params="${addFacet(params,facet.key,v.term)}">${v.display}</g:link> (${v.count})
                      </g:else>
                    </li>
                  </g:each>
                </ul>
              </div>
            </div>
            </g:if>
          </g:each>
        </div>


        <div class="span10">
          <div class="well">
             <g:if test="${hits}" >
                <div class="paginateButtons" style="text-align:center">
                    <g:if test=" ${params.int('offset')}">
                   Showing Results ${params.int('offset') + 1} - ${hits.totalHits < (params.int('max') + params.int('offset')) ? hits.totalHits : (params.int('max') + params.int('offset'))} of ${hits.totalHits}
                  </g:if>
                  <g:elseif test="${hits.totalHits && hits.totalHits > 0}">
                      Showing Results 1 - ${hits.totalHits < params.int('max') ? hits.totalHits : params.int('max')} of ${hits.totalHits}
                  </g:elseif>
                  <g:else>
                    Showing ${hits.totalHits} Results
                  </g:else>
                </div>

                <div id="resultsarea">
                  <table class="table table-bordered table-striped">
                    <thead>
                      <tr style="white-space: nowrap"><th>Package Name</th>
                          <th>Export</th>
                    </thead>
                    <tbody>
                      <g:each in="${hits}" var="hit">
                        <tr>
                          <td><g:link controller="${controller}" action="show" id="${hit.source.dbId}">${hit.source.name}</g:link>
                              <!--(${hit.score})-->
                              <span>(${hit.source.titleCount?:'Unknown number of'} titles)</span>
                          <ul>
                          <g:each in="${hit.source.identifiers}" var="ident">
                            <li>${ident}</li>
                          </g:each>
                          </ul>
                          </td>
                          <td>  <g:link action="pkg" params="${[format:'csv', id:hit.source.dbId]}">CSV With KBPlus header</g:link><br/>
            <g:link action="pkg" params="${[format:'csv',omitHeader:'Y', id:hit.source.dbId]}">CSV (KBART)</g:link><br/>
            <g:link action="pkg" params="${[format:'json',id:hit.source.dbId]}">JSON</g:link></td>
                        </tr>
                      </g:each>
                    </tbody>
                  </table>
                </div>
                <div class="paginateButtons" style="text-align:center">
                  <span><g:paginate controller="${controller}" action="index" params="${params}" next="Next" prev="Prev" total="${hits.totalHits}" /></span>
            </g:if>
          </div>
          </div>
        </div>
      </div>
    </div>



  </body>

</html>
