<cfsetting enablecfoutputonly="true" requesttimeout="3600" />
<cfset devMode = false />
<cfif server.coldfusion.productname eq "Railo">
	<cfset sAdministrator = "Railo Administrator">
<cfelse>
	<cfset sAdministrator = "CF Administrator">
</cfif>
<!---
	(c) Intergral 2008
--->

<!--- Combine GET & POST properties --->
<cfset properties = duplicate( form ) />
<cfset structAppend( properties, url, true ) />

<!--- Check for file asset retrieval --->
<cfif structKeyExists( properties, "file" )>
	<cfset browserOutput = getBrowserOutput( properties.file ) />

	<!--- Send file --->
	<cfcontent type="#browserOutput.mimeType#" reset="true" variable="#browserOutput.fileContent#" />

	<!--- Stop further processing --->
	<cfabort />
</cfif>

<!--- Define constants --->
<cfset thisVersion = structNew() />
<cfset thisVersion.major = 0 />
<cfset thisVersion.revision = 10 />
<cfset thisVersion.beta = 0 />

<!--- Perform setup actions --->
<cfif not structKeyExists(properties, "step")>
	<cfset latestVersion = checkForUpdate( thisVersion ) />
</cfif>

<!--- Define defaults --->
<cfparam name="properties.step" default="1" />
<cfif properties.step gte 2>
	<cfparam name="properties.overwrite" default="false" />
</cfif>

<!--- "Confirm" step --->
<cfif properties.step eq 3>
	<!--- Check for mode selection --->
	<cfif (not structKeyExists(properties, "mode")) OR (not listFindNoCase("wrap,unwrap", properties.mode))>
		<cfset properties.step = 2 />
		<cfset errorMsg = structNew() />
		<cfset errorMsg.title = "There is a problem with your input:" />
		<cfset errorMsg.messages = arrayNew(1) />
		<cfset arrayAppend(errorMsg.messages, "Please select a mode - Wrap or Un-Wrap.") />
	</cfif>
	<!--- Check CFIDE password --->
	<cfif not isValidCFIDEPassword(properties.password)>
		<cfif isDefined("errorMsg")>
			<cfset arrayAppend(errorMsg.messages, "Invalid #sAdministrator# password.") />
		<cfelse>
			<cfset properties.step = 2 />
			<cfset errorMsg = structNew() />
			<cfset errorMsg.title = "There is a problem with your input:" />
			<cfset errorMsg.messages = "Invalid #sAdministrator# password." />
		</cfif>
	</cfif>
</cfif>
<!--- "Options" step --->
<cfif properties.step eq 2>
	<!--- Check for DSN selection --->
	<cfif (not structKeyExists(properties, "selectDSN")) OR (not len(properties.selectDSN))>
		<cfset properties.step = 1 />
		<cfset errorMsg = structNew() />
		<cfset errorMsg.title = "There is a problem with your input:" />
		<cfset errorMsg.messages = "Please select at least one DSN." />
	</cfif>
</cfif>

<!--- Get datasources --->
<cfset stctDatasources = getDatasources() />
									
<cfoutput><?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
	<head>
		<meta http-equiv="Content-Style-Type" content="text/css" />
		<meta http-equiv="Content-Script-Type" content="text/javascript" />
		<script type="text/javascript" src="#cgi.script_name#?file=jdbc_wrap.js"></script>
		<title>FusionReactor JDBC Wrapper Tool - v#thisVersion.major#.#thisVersion.revision#<cfif thisVersion.beta> (Beta)</cfif></title>
		<style type="text/css">
			body {
				font-family: Arial, sans-serif;
			}
			h1 {
				text-align: center;
				font-size: 1.5em;
			}
			table {
				margin: 0 auto;
				border-collapse: collapse;
			}
			.arrow {
				padding: 0 10px;
			}
			.earlierStep {
				border-bottom: 1px solid ##aaa;
			}
			.currentStep {
				border-bottom: 1px solid ##ccc;
				font-style: italic;
			}
			div.alert div {
				font-weight: bold;
			}
			div.alert {
				margin: 40px auto;
				border: 2px solid ##f00;
				padding: 20px;
				background-color: ##ddd;
				width: 70%;
			}

			table.dsns {
				min-width: 75%;
				margin: 0 auto;
				margin-top: 20px;
			}
			.dsns td {
				margin: 0;
				padding: 6px 4px;
				border: 1px solid ##ddd;
			}
			.dsns thead td {
				font-weight: bold;
				text-align: center;
			}
			.dsns td.tickbox {
				text-align: center;
			}
			.dsns tr.oddRow td {
				background-color: ##eee;
			}
			.dsns tfoot tr td div input {
				text-align: center;
			}
			.dsns thead td.last div .spacer {
				margin: 0 2px;
			}
			.dsns thead td.last div {
				margin-top: 4px;
				font-size: 0.8em;
				font-weight: normal;
			}
			.dsns thead td.last,
			.dsns thead tr.last td {
				border-bottom: 4px solid ##ddd;
			}
			.dsns tfoot tr td {
				border-top: 4px solid ##ddd;
				font-size: 0.8em;
			}
			.dsns tfoot tr td.buttons {
				text-align: right;
			}
			fieldset {
				border: 0;
			}
			.spacer {
				font-weight: bold;
				color: ##777;
				margin: 0 10px;
			}
			span##paging a {
				font-size: 1.2em;
				text-decoration: none;
				color: ##777;
			}
			.options {
				margin-top: 20px;
				width: 400px;
			}
			.options td {
				vertical-align: top;
			}
			.options label.main {
				font-weight: bold;
			}
			.options .bottomBorder td {
				padding-bottom: 10px;
			}
			.options .topBorder td {
				border-top: 1px solid ##ddd;
				padding-top: 10px;
			}
			.options tfoot td {
				border-top: 1px solid ##ddd;
				padding-top: 10px;
				text-align: right;
			}
			.options input.textInput {
				width: 95%;
			}
			div.confirm {
				width: 550px;
				margin: 0 auto;
			}
			div.confirm .buttons {
				border-top: 1px solid ##ddd;
				padding-top: 10px;
				text-align: right;
			}
			div.confirm p {
				border-bottom: 1px solid ##ddd;
				padding-bottom: 10px;
			}
			.results {
				margin: 0 auto;
				margin-top: 20px;
			}
			.results thead td {
				font-weight: bold;
			}
			.results tfoot td {
				padding: 0;
				padding-top: 10px;
				text-align: right;
				border: 0;
			}
			.results td {
				border: 1px solid ##ddd;
				padding: 4px 10px;
				font-size: 0.8em;
			}
			.results .oddRow td {
				background-color: ##eee;
			}
			.results tr.errorRow td {
				background-color: ##f77;
			}
			.errorTitle {
				font-weight: bold;
			}
			.verified {
				color: green;
				font-weight: bold;
			}
			p {
				font-size: 0.8em;
			}
		</style>
	</head>
	<body>
		<!--- Header --->
		<h1>FusionReactor JDBC Wrapper Tool - v#thisVersion.major#.#thisVersion.revision#<cfif thisVersion.beta> (Beta)</cfif></h1>

		<!--- No JS warning --->
		<noscript>
			<div class="alert">
				<div>This page requires JavaScript to be enabled</div>
				Without JavaScript enabled, this page may not function as desired.
			</div>
		</noscript>

		<!--- Latest version check display --->
		<cfif isDefined("latestVersion") AND (latestVersion.noConnection OR latestVersion.updateAvailable)>
			<div class="alert">
				<cfif latestVersion.noConnection>
					<!--- Couldn't connect to server, behind proxy / no internet etc --->
					<div>No connection to update server.</div>
					Please check for updates manually.
				<cfelse>
					<!--- New version found --->
					<div>A new version of this tool
					<cfif thisVersion.beta AND (latestVersion.beta.major gt thisVersion.major OR (latestVersion.beta.major eq thisVersion.major AND latestVersion.beta.revision gt thisVersion.revision))>
						<!--- New beta version --->
						(#latestVersion.beta.major#.#latestVersion.beta.revision# Beta)
					<cfelse>
						<!--- New stable version --->
						(#latestVersion.stable.major#.#latestVersion.stable.revision#)
					</cfif>
					is available.</div>
				</cfif>
				You can <a href="http://www.fusion-reactor.com/labs/developers/jbdc_tool.cfm?version=#thisVersion.major#.#thisVersion.revision#&amp;beta=#thisVersion.beta#">read about updates</a> here.
			</div>
		</cfif>

		<!--- Generic error message display --->
		<cfif isDefined("errorMsg")>
			<div class="alert">
				<cfif structKeyExists(errorMsg, "title")>
					<div>#errorMsg.title#</div>
				</cfif>
				<cfif structKeyExists(errorMsg, "messages")>
					<cfif isArray(errorMsg.messages)>
						<cfif arrayLen(errorMsg.messages) gt 1>
							<ul>
								<cfloop from="1" to="#arrayLen(errorMsg.messages)#" index="i">
									<li>#errorMsg.messages[i]#</li>
								</cfloop>
							</ul>
						<cfelse>
							#errorMsg.messages[1]#
						</cfif>
					<cfelse>
						#errorMsg.messages#
					</cfif>
				</cfif>
			</div>
		</cfif>

		<!--- Current step display --->
		<table>
			<tr>
				<td#classDef(properties.step, 1)#>Select Datasources</td>
				<td#classDef(properties.step, 1, "arrow")#>&raquo;</td>
				<td#classDef(properties.step, 2)#>Options</td>
				<td#classDef(properties.step, 2, "arrow")#>&raquo;</td>
				<td#classDef(properties.step, 3)#>Confirm</td>
				<td#classDef(properties.step, 3, "arrow")#>&raquo;</td>
				<td#classDef(properties.step, 4)#>Results</td>
			</tr>
		</table>

		<!--- Self-posting form (all steps) --->
		<form action="#htmlEditFormat(CGI.script_name)#" method="post" id="mainForm">
			<fieldset>
				<cfif properties.step eq 4>
					<!--- At "Results" step; next step is start --->
					<input type="hidden" name="step" id="step" value="1" />
				<cfelse>
					<!--- Goto next step --->
					<input type="hidden" name="step" id="step" value="#properties.step+1#" />

					<!--- Properties to exclude --->
					<cfset skipProperties = arrayNew(1) />
					<cfset arrayAppend( skipProperties, "fieldnames,step,go,mode,selectDSN,perPage,pageNum,name_filter,driver_filter,host_filter,port_filter,database_filter" ) />
					<cfset arrayAppend( skipProperties, "fieldnames,step,go,mode,password,overwrite" ) />
					<cfset arrayAppend( skipProperties, "fieldnames,step,go" ) />

					<!--- Maintain properties --->
					<cfloop collection="#properties#" item="key">
						<cfif not listFindNoCase( skipProperties[properties.step], key )>
							<input type="hidden" name="#htmlEditFormat(key)#" value="#htmlEditFormat(properties[key])#" />
						</cfif>
					</cfloop>
				</cfif>

				<cfif properties.step eq 1>
					<!--- DSN list --->
					<table class="dsns">
						<thead>
							<tr>
								<td class="last" rowspan="2">
									Select<br />
									<div>
										<a href="##" onclick="selectAll(true);">All</a>
										<span class="spacer">|</span>
										<a href="##" onclick="selectAll(false);">None</a>
									</div>
								</td>
								<td>DSN Name</td>
								<td>Driver</td>
								<td>Host</td>
								<td>Port</td>
								<td>Database</td>
							</tr>
							<tr class="last">
								<cfparam name="properties.name_filter" default="" />
								<cfparam name="properties.driver_filter" default="" />
								<cfparam name="properties.host_filter" default="" />
								<cfparam name="properties.port_filter" default="" />
								<cfparam name="properties.database_filter" default="" />

								<td><input type="text" name="name_filter" id="name_filter" size="10" value="#htmlEditFormat(properties.name_filter)#" /></td>
								<td><input type="text" name="driver_filter" id="driver_filter" size="22" value="#htmlEditFormat(properties.driver_filter)#" /></td>
								<td><input type="text" name="host_filter" id="host_filter" size="10" value="#htmlEditFormat(properties.host_filter)#" /></td>
								<td><input type="text" name="port_filter" id="port_filter" size="6" value="#htmlEditFormat(properties.port_filter)#" /></td>
								<td><input type="text" name="database_filter" id="database_filter" size="46" value="#htmlEditFormat(properties.database_filter)#" /></td>
							</tr>
						</thead>
						<tfoot>
							<tr>
								<td colspan="5">
									<div>
										<!--- Results per page selector --->
										Show
										<cfparam name="properties.perPage" default="10" />
										<select name="perPage" id="perPage" onchange="updateUI();">
											<option value="-1">all</option>
											<cfloop list="2,5,10,20,50,100" index="perPageCount">
												<option value="#perPageCount#"<cfif properties.perPage eq perPageCount> selected="selected"</cfif>>#perPageCount#</option>
											</cfloop>
										</select>
										results per page

										<!--- Paging controls --->
										<span id="paging">
											<span class="spacer">|</span>
											<a href="##" onclick="goPageDown();return false;">&laquo;</a>
											Page
											<cfparam name="properties.pageNum" default="1" />
											<input name="pageNum" id="pageNum" value="#htmlEditFormat(properties.pageNum)#" size="1" onchange="updateUI();" />
											of <span id="totalPages">Y</span>
											<a href="##" onclick="goPageUp();return false;">&raquo;</a>
										</span>

										<!--- Filter result count --->
										<div id="results_footer">
											<span class="spacer">|</span>
											<span id="filter_result">X</span> results matching filter rules.
										</div>
									</div>
								</td>
								<td class="buttons">
									<input type="submit" name="go" value="Next &raquo;" />
								</td>
							</tr>
						</tfoot>
						<tbody>
							<!--- Order the DSNs by name --->
							<cfset keyList = structKeyList(stctDatasources) />
							<cfset keyList = listSort( keyList, "textNoCase" ) />

							<cfloop list="#keyList#" index="dsnKey">
								<cfset thisDSN = stctDatasources[dsnKey] />
								<tr>
									<cfparam name="properties.selectDSN" default="" />
									<td class="tickbox"><input class="checkbox" type="checkbox" name="selectDSN" id="#htmlEditFormat(thisDSN.name)#" value="#htmlEditFormat(thisDSN.name)#"<cfif listFindNoCase(properties.selectDSN, thisDSN.name)> checked="checked"</cfif> /></td>
									<td><label for="#htmlEditFormat(thisDSN.name)#">#htmlShort(thisDSN.name)#</label></td>
									<td><span class="withTitle" title="#htmlEditFormat(thisDSN.class)#">#htmlEditFormat(thisDSN.driver)#</span></td>
									<cfif isDefined("thisDSN.urlmap.connectionprops.host")>
										<td>#htmlShort(thisDSN.urlmap.connectionprops.host)#</td>
									<cfelse>
										<td class="not_defined"></td>
									</cfif>
									<cfif isDefined("thisDSN.urlmap.connectionprops.port") and thisDSN.urlmap.connectionprops.port neq 0>
										<td>#htmlShort(thisDSN.urlmap.connectionprops.port)#</td>
									<cfelse>
										<td class="not_defined"></td>
									</cfif>
									<cfif isDefined("thisDSN.urlmap.connectionprops.database")>
										<td>#htmlShort(thisDSN.urlmap.connectionprops.database)#</td>
									<cfelse>
										<td class="not_defined"></td>
									</cfif>
								</tr>
							</cfloop>

							<!--- No filter results display --->
							<tr id="no_results" style="display: none;">
								<td colspan="6">No results for filter. Try broadening your search pattern(s).</td>
							</tr>
						</tbody>
					</table>
				<cfelseif properties.step eq 2>
					<!--- "Options" step --->
					<table class="options">
						<tbody>
							<tr class="bottomBorder">
								<td colspan="2">
									#listLen(properties.selectDSN)# datasource(s) selected.
								</td>
							</tr>
							<tr class="topBorder bottomBorder">
								<td rowspan="2">
									<!--- Intelligent mode default depending on first selected DSN --->
									<cfif stctDatasources[listFirst(properties.selectDSN)].class eq "com.intergral.fusionreactor.jdbc.Wrapper">
										<cfparam name="properties.mode" default="unwrap" />
									<cfelse>
										<cfparam name="properties.mode" default="wrap" />
									</cfif>
									<label class="main">Tool mode:</label>
								</td>
								<td>
									<input type="radio" name="mode" value="wrap" id="wrap"<cfif properties.mode eq "wrap"> checked="checked"</cfif> /><label for="wrap">Wrap</label>
								</td>
							</tr>
							<tr class="bottomBorder">
								<td>
									<input type="radio" name="mode" value="unwrap" id="unwrap"<cfif properties.mode eq "unwrap"> checked="checked"</cfif> /><label for="unwrap">Un-Wrap</label>
								</td>
							</tr>
							<tr class="topBorder bottomBorder">
								<td>
									<label class="main" for="password">#sAdministrator# Password:</label>
								</td>
								<td>
									<input type="password" name="password" id="password" class="textInput" />
								</td>
							</tr>
							<tr class="topBorder bottomBorder">
								<td colspan="2">
									<input type="checkbox" name="overwrite" id="overwrite" value="true"<cfif properties.overwrite> checked="checked"</cfif> />
									<label for="overwrite">Overwrite existing datasource(s)?</label>
									<cfif server.coldfusion.productname eq "Railo">
										<p>
											<strong>Note</strong>: You may need to restart your application server for wrapping to take effect when overwriting existing datasources.
										</p>
									</cfif>
								</td>
							</tr>
						</tbody>
						<tfoot>
							<tr>
								<td colspan="2">
									<input type="button" name="go" value="&laquo; Back" onclick="goBack();" />
									<span class="spacer">|</span>
									<input type="submit" name="go" value="Next &raquo;" />
								</td>
							</tr>
						</tfoot>
					</table>
				<cfelseif properties.step eq 3>
					<!--- "Confirm" step --->
					<div class="confirm">
						<p>
							<!--- Mode? --->
							<cfif properties.mode eq "wrap">
								Wrap
							<cfelse>
								Un-wrap
							</cfif>

							the below named datasources

							<!--- Overwrite? --->
							<cfif properties.overwrite>
								overwriting the selected #listLen(properties.selectDSN)# entries.
							<cfelse>
								resulting in an extra #listLen(properties.selectDSN)# entries.
							</cfif>
						</p>

						<h3>Selected DSN List</h3>
						<ul>
							<cfloop list="#properties.selectDSN#" index="dsnName">
								<li>#dsnName#</li>
							</cfloop>
						</ul>
						<div class="buttons">
							<input type="button" name="go" value="&laquo; Back" onclick="goBack();" />
							<span class="spacer">|</span>
							<input type="submit" name="go" value="Confirm" />
						</div>
					</div>
				<cfelseif properties.step eq 4>
					<!--- "Results" step --->
					<table class="results">
						<thead>
							<tr>
								<td>DSN Name</td>
								<td>Status</td>
							</tr>
						</thead>
						<tfoot>
							<tr>
								<td colspan="2">
									<input type="submit" name="go" value="Start again &raquo;" />
								</td>
							</tr>
						</tfoot>
						<tbody>
							<cfset oddRow = false />
							<cfloop list="#properties.selectDSN#" index="dsnName">
								<cfset className = "" />
								<cfset oddRow = not oddRow />
								<cfif oddRow>
									<cfset className = listAppend(className, "oddRow", " ") />
								</cfif>

								<!--- Configure method arguments --->
								<cfif properties.overwrite>
									<cfset newDSNName = dsnName />
									<cfset checkDestinationFree = false />
								<cfelse>
									<cfset checkDestinationFree = true />

									<cfif properties.mode eq "wrap">
										<cfset newDSNName = dsnName & "_WRAPPED" />
									<cfelse>
										<cfset newDSNName = dsnName & "_UN_WRAPPED" />
									</cfif>
								</cfif>

									<!--- Define DSN properties --->
									<cfset initialDSNcopy = plainCopy(stctDatasources[dsnName]) />
									<cfif properties.mode eq "wrap">
										<cfset newDSNdata = doWrap( initialDSNcopy ) />
									<cfelse>
										<cfset newDSNdata = doUnWrap( initialDSNcopy ) />
									</cfif>
									<!--- Result defaults --->
									<cfset result = structNew() />
									<cfset result.verified = true />

									<!--- Try and add the new DSN --->
									<cfset addDatasource( properties.password, newDSNName, newDSNdata, checkDestinationFree) />

									<!--- Verify the new DSN --->
									<cfset vData = verifyDSN( newDSNName ) />
									<cfset result.verified = vData.valid />
									<cfif not result.verified>
										<cfset result.errorTitle = "Verification ERROR: " & vData.errorType />
										<cfset result.errorMessage = vData.errorMessage & "<br />" & vData.errorDetail />
									</cfif>

								<cftry>
									<cfcatch type="dataSourceInUse">
										<!--- New DSN name already exists --->
										<cfset result.verified = false />
										<cfset result.errorTitle = cfcatch.message />
									</cfcatch>
									<cfcatch type="cannotUnWrap">
										<!--- Old DSN not wrapped using this tool --->
										<cfset result.verified = false />
										<cfset result.errorTitle = "Cannot un-wrap datasource named '#dsnName#'." />
										<cfset result.errorMessage = "This tool can only un-wrap DSNs wrapped with this tool." />
									</cfcatch>
									<cfcatch>
										<!--- Un-handled error type --->
										<cfset result.verified = false />
										<cfset result.errorTitle = "Un-handled ERROR: #cfcatch.type#" />
										<cfset result.errorMessage = cfcatch.message & " [" & cfcatch.detail & "]" />
									</cfcatch>
								</cftry>

								<cfif not result.verified>
									<!--- Change row class --->
									<cfset className = listAppend(className, "errorRow", " ") />
								</cfif>

								<tr<cfif len(className)> class="#className#"</cfif>>
									<td>#htmlEditFormat(newDSNName)#</td>
									<td>
										<cfif result.verified>
											<span class="verified">Verified OK</span>
										<cfelse>
											<span class="errorTitle">#result.errorTitle#</span>
											<cfif structKeyExists( result, "errorMessage" )>
												<br />
												#result.errorMessage#
											</cfif>
										</cfif>
									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</cfif>
			</fieldset>
		</form>
	</body>
</html>
</cfoutput>

<!--- Helper functions --->
<cffunction name="getDatasources" access="private" returntype="struct" output="true" description="Return the DSNs and their properties.">
	<cfset var localx = structNew() />
	<cfset var key   = "">
	<cfset var stTmp = structNew() >

	<cfset localx.dsService = createObject("java", "coldfusion.server.ServiceFactory").DataSourceService />
	<cfif server.coldfusion.productname eq "Railo">
		<cfset localx = localx.dsService.getDataSources()>
		<cfloop collection="#localx#" item="key">
			<cfset stTmp[key].name     = key>
			<cfset stTmp[key].class    = localx[key].getDataSourceDef().getClassName()>
			<cfif findNoCase(".mysql.", stTmp[key].class)>
				<cfset stTmp[key].driver = "MySQL 5">
			<cfelseif findNoCase(".db2.", stTmp[key].class)>
				<cfset stTmp[key].driver = "DB2 Driver">
			<cfelseif findNoCase(".firebirdsql.", stTmp[key].class)>
				<cfset stTmp[key].driver = "Firebird Driver">
			<cfelseif findNoCase(".h2.", stTmp[key].class)>
				<cfset stTmp[key].driver = "H2 Driver">
			<cfelseif findNoCase(".hsqldb.", stTmp[key].class)>
				<cfset stTmp[key].driver = "HSQLDB Driver">
			<cfelseif findNoCase(".sqlserver.", stTmp[key].class)>
				<cfset stTmp[key].driver = "Microsoft SQL Server Driver">
			<cfelseif findNoCase(".jtds.", stTmp[key].class)>
				<cfset stTmp[key].driver = "JDTS MSSQL/Sybase Driver">
			<cfelseif findNoCase(".odbc.", stTmp[key].class)>
				<cfset stTmp[key].driver = "ODBC Driver">
			<cfelseif findNoCase("oracle.", stTmp[key].class)>
				<cfset stTmp[key].driver = "Oracle Driver">
			<cfelseif findNoCase(".postgresql.", stTmp[key].class)>
				<cfset stTmp[key].driver = "PostGre SQL Driver">
			<cfelse>
				<cfset stTmp[key].driver = "Other Driver">
			</cfif>
			<cfset stTmp[key].url = localx[key].getDatasourceDef().getURL()>
			<cfset stTmp[key].urlmap.connectionprops.host     = localx[key].getDatasourceDef().getHost()>
			<cfset stTmp[key].urlmap.connectionprops.port     = localx[key].getDatasourceDef().getPort()>
			<cfset stTmp[key].urlmap.connectionprops.database = localx[key].getDatasourceDef().getDatabase()>
		</cfloop>
		<cfset localx = stTmp>
	<cfelse>
		<cfreturn localx.dsService.getDataSources()>
	</cfif>
	<cfreturn localx />
</cffunction>

<cffunction name="dsnInUse" access="private" returntype="boolean" output="false" description="Check if a given DSN name is already in use.">
	<cfargument name="dsnName" type="string" output="false">

	<cfset var ds = getDatasources() />

	<cfreturn structKeyExists( ds, arguments.dsnName ) />
</cffunction>

<cffunction name="plainCopy" access="private" returntype="struct" output="false" description="Make a raw copy of the DSN properties.">
	<cfargument name="dsnObj" type="struct" required="true" />

	<cfset var localx = structNew() />

	<cfset localx.copyDSN = structNew() />

	<cfloop collection="#arguments.dsnObj#" item="localx.key">
		<cfset localx.copyDSN[localx.key] = arguments.dsnObj[localx.key] />
	</cfloop>
	<cfif isDefined("arguments.dsnObj.urlmap.connectionprops.host")>
		<cfset localx.copyDSN.host = arguments.dsnObj.urlmap.connectionprops.host />
	</cfif>
	<cfif isDefined("arguments.dsnObj.urlmap.connectionprops.port")>
		<cfset localx.copyDSN.port = arguments.dsnObj.urlmap.connectionprops.port />
	</cfif>
	<cfif isDefined("arguments.dsnObj.urlmap.connectionprops.database")>
		<cfset localx.copyDSN.database = arguments.dsnObj.urlmap.connectionprops.database />
	</cfif>
	<cfif isDefined("arguments.dsnObj.urlmap.connectionprops.databasefile")>
		<cfset localx.copyDSN.databasefile = arguments.dsnObj.urlmap.connectionprops.databasefile />
	</cfif>

	<cfset localx.copyDSN.encryptPassword = false />

	<cfreturn localx.copyDSN />
</cffunction>

<cffunction name="doWrap" access="private" returntype="struct" output="false" description="Alter DSN properties to those of a wrapped DSN.">
	<cfargument name="unwrappedDSN" type="struct" required="true" />

	<cfset var localx = structNew() />
	<cfset localx.frDSN = structNew() />

	<cfset localx.frDSN = duplicate(arguments.unwrappedDSN) />

	<cfset localx.frDSN.url = "jdbc:fusionreactor:wrapper:{" & arguments.unwrappedDSN.url & "};driver=" & arguments.unwrappedDSN.class & ";name=" & arguments.unwrappedDSN.name />
	<cfset localx.frDSN.class = "com.intergral.fusionreactor.jdbc.Wrapper" />
	<cfset localx.frDSN.driver = "FusionReactor Wrapper (#arguments.unwrappedDSN.driver#)" />
	<cfset localx.frDSN.encryptpassword = false />

	<cfreturn localx.frDSN />
</cffunction>

<cffunction name="doUnWrap" access="private" returntype="struct" output="false" description="Alter DSN properties to those of an un-wrapped DSN.">
	<cfargument name="wrappedDSN" type="struct" required="true" />

	<cfset var localx = structNew() />
	<cfset localx.frDSN = structNew() />

	<cftry>
		<cfset localx.frDSN = duplicate(arguments.wrappedDSN) />

		<cfset localx.oldURL_start = find("{", arguments.wrappedDSN.url) />
		<cfset localx.oldURL_end = len(arguments.wrappedDSN.url) - find("}", reverse(arguments.wrappedDSN.url)) />
		<cfset localx.oldURL = mid(arguments.wrappedDSN.url, localx.oldURL_start +1, localx.oldURL_end - localx.oldURL_start) />

		<cfset localx.oldDriver_start = find("};driver=", arguments.wrappedDSN.url) />
		<cfset localx.oldDriver_end = find(";name=", arguments.wrappedDSN.url, localx.oldDriver_start) />
		<cfset localx.oldDriver = mid(arguments.wrappedDSN.url, localx.oldDriver_start + 9, localx.oldDriver_end - (localx.oldDriver_start + 9)) />

		<cfset localx.frDSN.url = localx.oldURL />
		<cfset localx.frDSN.class = localx.oldDriver />
		<cfset localx.frDSN.driver = replaceNoCase(arguments.wrappedDSN.driver, "FusionReactor Wrapper (", "") />
		<cfset localx.frDSN.driver = left(localx.frDSN.driver, len(localx.frDSN.driver)-1) />
		<cfset localx.frDSN.encryptpassword = false />

		<cfcatch>
			<cfthrow type="cannotUnWrap" />
		</cfcatch>
	</cftry>

	<cfreturn localx.frDSN />
</cffunction>

<cffunction name="addDatasource" access="private" returntype="void" output="false" description="Add a DSN to the system.">
	<cfargument name="cfAdminPassword" type="string" required="true" />
	<cfargument name="datasourceName" type="string" required="true" />
	<cfargument name="dataSourceProperties" type="struct" required="true" />
	<cfargument name="checkDestinationAvailable" type="boolean" required="false" default="true" />
	
	<cfset var localx = structNew() />

	<cfif arguments.checkDestinationAvailable and dsnInUse(arguments.datasourceName)>
		<cfthrow type="dataSourceInUse" message="Datasource name '#arguments.datasourceName#' is already in use." />
	</cfif>
	<cfif server.coldfusion.productname eq "Railo">
		<cfinclude template="railo_createDatasource.cfm">
	<cfelse>
		<cfset localx.adminObj = createObject("component","cfide.adminapi.administrator") />
		<!--- cfset localx.adminObj.login(arguments.cfAdminPassword) / --->
	
		<cfset localx.datasource = createObject("component","cfide.adminapi.datasource") />
	
		<cfset localx.dsProps = duplicate( arguments.dataSourceProperties ) />
		<cfset localx.dsProps.name = arguments.datasourceName />
	
		<cfset localx.datasource.setOther( argumentCollection=localx.dsProps ) />
	</cfif>
</cffunction>

<cffunction name="htmlShort" access="private" returntype="string" output="false" description="Provide a HTML snippet with roll-over for full content.">
	<cfargument name="fullText" type="string" required="true" />
	<cfargument name="length" type="numeric" required="false" default="40" />

	<cfif len(arguments.fullText) lte arguments.length>
		<cfreturn htmlEditFormat(arguments.fullText) />
	</cfif>

	<cfreturn '<span title="#htmlEditFormat(arguments.fullText)#" class="shortened">...#htmlEditFormat(right(arguments.fullText, arguments.length))#</span>' />
</cffunction>

<cffunction name="getBrowserOutput" access="private" returntype="struct" output="false" description="Helper for single file asset downloads.">
	<cfargument name="fileName" type="string" required="true" />

	<cfset var localx = structNew() />
	<cfset localx.result = structNew() />

	<cfset localx.result.mimeType = "text/javascript" />
	<cfset localx.result.fileName = arguments.fileName />

	<cfswitch expression="#arguments.fileName#">
		<cfcase value="jdbc_wrap.js">
			<cfset localx.result.fileContent = getJSContent() />
		</cfcase>
		<cfdefaultcase>
			<cfset localx.result.mimeType = "text/plain" />
			<cfset localx.result.fileContent = "Unknown file '#arguments.fileName#'." />
		</cfdefaultcase>
	</cfswitch>

	<cfif isDefined("devMode") and devMode>
		<cffile action="read" file="#expandPath('dev/#arguments.fileName#')#" variable="localx.result.fileContent" />
	</cfif>

	<cfif not isBinary( localx.result.fileContent )>
		<cfset localx.result.fileContent = toBinary( toBase64( localx.result.fileContent ) ) />
	</cfif>

	<cfreturn localx.result />
</cffunction>

<cffunction name="getJSContent" access="private" returntype="string" output="false" description="Storage for single file asset (jdbc_wrap.js).">
	<cfset var output = "" />
	<cfsavecontent variable="output">
<cfoutput>
window.onload = function() { init() };

var updateTimer = 0;

function init() {
	if ($("step").value == 2)
	{
		$("name_filter").onkeydown = function() { clearTimeout(updateTimer); updateTimer = setTimeout(updateUI, 100); };
		$("driver_filter").onkeydown = function() { clearTimeout(updateTimer); updateTimer = setTimeout(updateUI, 100); };
		$("host_filter").onkeydown = function() { clearTimeout(updateTimer); updateTimer = setTimeout(updateUI, 100); };
		$("port_filter").onkeydown = function() { clearTimeout(updateTimer); updateTimer = setTimeout(updateUI, 100); };
		$("database_filter").onkeydown = function() { clearTimeout(updateTimer); updateTimer = setTimeout(updateUI, 100); };
		updateUI();
	}
}

function $(elem) {
	return document.getElementById(elem);
}

function updateUI()
{
	var trElems = document.getElementsByTagName("table")[1].getElementsByTagName("tbody")[0].getElementsByTagName("tr");

	var posNameLookup = new Object();
	posNameLookup['1'] = "name";
	posNameLookup['2'] = "driver";
	posNameLookup['3'] = "host";
	posNameLookup['4'] = "port";
	posNameLookup['5'] = "database";

	var shownRows = 0;

	for( var rowNum=0; rowNum< trElems.length-1; rowNum++)
	{
		var showRow = true;

		for (var dataPos in posNameLookup)
		{
			// Does content in column "dataPos" match regexp in "posNameLookup[dataPos]" filter field
			var pureContent = getContent( trElems[rowNum].getElementsByTagName("td")[ dataPos ].innerHTML );
			var filterInput = $( posNameLookup[dataPos] + "_filter" ).value;
			var filterRegExp = new RegExp( filterInput, "i" );

			if (filterInput.length) {
				showRow = showRow && (filterRegExp.exec(pureContent) != null);
			}
		}

		if (showRow) {
			trElems[rowNum].style.display = "";
			shownRows++;
			if (!(shownRows % 2)) {
				trElems[rowNum].className = "";
			} else {
				trElems[rowNum].className = "oddRow";
			}
		} else {
			trElems[rowNum].style.display = "none";
		}
	}

	if ( selectVal("perPage") == "-1" )
	{
		$("paging").style.display = "none";
		$("totalPages").innerHTML = 1;
	} else {
		var totalPages = Math.ceil(shownRows / selectVal("perPage"));
		$("totalPages").innerHTML = totalPages;
		if (totalPages > 1)
		{
			$("paging").style.display = "inline";
		} else {
			$("paging").style.display = "none";
		}
	}

	if (shownRows == 0) {
		$("no_results").style.display = "";
		$("results_footer").style.display = "none";
		$("paging").style.display = "none";
	} else {
		$("no_results").style.display = "none";
		$("results_footer").style.display = "inline";
		$("filter_result").innerHTML = shownRows;
	}

	var pageNum = $("pageNum").value;
	var maxPage = parseInt( $("totalPages").innerHTML );

	if ( isNaN(pageNum) ) {
		$("pageNum").value = 1;
		pageNum = 1;
	}

	pageNum = Math.max(1, pageNum);
	pageNum = Math.min(maxPage, pageNum);

	$("pageNum").value = pageNum;

	if (maxPage > 1)
	{
		var perPage = selectVal("perPage");
		var startRow = (pageNum-1) * perPage;
		var endRow = pageNum * perPage;

		var rCounter = 0;
		var pgDisplay = 0;

		for( var rowNum=0; rowNum< trElems.length-1; rowNum++)
		{
			if (trElems[rowNum].style.display != "none")
			{
				// Row shown. Have action to perform
				if (rCounter >= startRow && rCounter < endRow )
				{
					if (!(pgDisplay % 2))
					{
						trElems[rowNum].className = "oddRow";
					} else {
						trElems[rowNum].className = "";
					}
					pgDisplay++;
				} else {
					trElems[rowNum].style.display = "none";
				}
				rCounter++;
			}
		}
	}
}

function selectVal(selectID) {
	return $(selectID).value;
}

function goPageUp() {
	pageGo(1);
}

function goPageDown() {
	pageGo(-1);
}

function pageGo(adder) {
	var pageNum = $("pageNum").value;

	if ( ! isNaN(pageNum) ) {
		pageNum = parseInt(pageNum);
		pageNum += adder;
		$("pageNum").value = pageNum;
	}

	updateUI();
}

function getContent( htmlCode )
{
	// Return SPAN title attribute or displayed content
	var spanFinder = '<span class="withTitle" title="';
	var spanStart = htmlCode.indexOf(spanFinder);
	if (spanStart != -1)
	{
		var spanEnd = htmlCode.indexOf( '"', spanStart + spanFinder.length );
		var titleAttrib = htmlCode.substring( spanStart + spanFinder.length, spanEnd );
		var content = htmlCode.replace(/(<([^>]+)>)/ig,"");
		return content + titleAttrib;
	} else {
		return htmlCode.replace(/(<([^>]+)>)/ig,"");
	}
}

function selectAll(setter)
{
	var trElems = document.getElementsByTagName("table")[1].getElementsByTagName("tbody")[0].getElementsByTagName("tr");

	for (var x=0;x<trElems.length-1;x++)
	{
		if (trElems[x].style.display != "none") {
			var inputs = trElems[x].getElementsByTagName("input");
			for (var i=0; i<inputs.length; i++)
			{
				if (inputs[i].className == "checkbox")
				{
					inputs[i].checked = setter;
				}
			}
		}
	}
}

function goBack()
{
	$('step').value-=2
	var form = $('mainForm');
	form.submit();
}
</cfoutput>
	</cfsavecontent>
	<cfreturn output />
</cffunction>

<cffunction name="checkForUpdate" access="private" returntype="struct" output="false" description="New version URL checker.">
	<cfargument name="runningVersion" type="struct" required="true" />

	<cfset var localx = structNew() />

	<!--- Setup defaults --->
	<cfset localx.result = structNew() />
	<cfset localx.result.updateAvailable = false />
	<cfset localx.result.noConnection = false />

	<cftry>
		<!--- Get update packet --->
		<cfhttp url="http://www.fusion-reactor.com/labs/developers/jbdc_tool/version.cfm?version=#runningVersion.major#.#runningVersion.revision#&beta=#runningVersion.beta#&xml=true" timeout="5" throwonerror="true" result="localx.httpResult" />

		<!--- Check valid content --->
		<cfif not isWDDX(localx.httpResult.fileContent)>
			<cfthrow type="com.intergral.generic.error" message="Update content is not valid XML-WDDX packet." />
		</cfif>

		<!--- Decode content --->
		<cfwddx action="wddx2cfml" input="#localx.httpResult.fileContent#" output="localx.wddxPacket" />
		<cfset structAppend( localx.result, localx.wddxPacket, true ) />

		<cfcatch>
			<!--- Handle problems with generic "no connection" --->
			<cfset localx.result.noConnection = true />
		</cfcatch>
	</cftry>

	<cfreturn localx.result />
</cffunction>

<cffunction name="classDef" access="private" returntype="void" output="true" description="Display helper for current step display table.">
	<cfargument name="currentStep" type="numeric" required="true" />
	<cfargument name="testStep" type="numeric" required="true" />
	<cfargument name="className" type="string" required="false" default="" />

	<cfif arguments.currentStep eq arguments.testStep and not len(arguments.className)>
		<cfset arguments.className = listAppend( arguments.className, "currentStep", " " ) />
	</cfif>
	<cfif arguments.currentStep gt arguments.testStep>
		<cfset arguments.className = listAppend( arguments.className, "earlierStep", " " ) />
	</cfif>

	<cfif len(trim(arguments.className))>
		<cfoutput> class="#trim(arguments.className)#"</cfoutput>
	</cfif>
</cffunction>

<cffunction name="isValidCFIDEPassword" access="private" returntype="boolean" output="false" description="Check if CFIDE password is valid.">
	<cfargument name="testPassword" type="string" required="true" />

	<cfset var localx = structNew() />
	<cfif server.coldfusion.productname eq "Railo">
		<cftry>
			<cfinclude template="railo_connect.cfm">
	
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
	<cfelse>
		<cftry>
			<cfset localx.adminObj = createObject("component","cfide.adminapi.administrator") />
			<!--- cfset localx.adminObj.login(arguments.testPassword) / --->
	
			<cfreturn localx.adminObj.isAdminUser() />
	
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cfif>
	<cfreturn true>
</cffunction>

<cffunction name="verifyDSN" access="private" returntype="struct" output="false" description="Validate a DSN connection.">
	<cfargument name="dsn" type="string" required="true" />

	<cfset var localx = structNew() />
	<cfset localx.result = structNew() />
	<cfset localx.dsService = createObject("java", "coldfusion.server.ServiceFactory").DataSourceService />

	<cftry>
		<cfset localx.result.valid = localx.dsService.verifydatasource(arguments.dsn) />
		<cfcatch>
			<cfset localx.result.valid = false />
			<cfset localx.result.errorType = cfcatch.type />
			<cfset localx.result.errorMessage = cfcatch.message />
			<cfset localx.result.errorDetail = cfcatch.detail />
		</cfcatch>
	</cftry>

	<cfreturn localx.result />
</cffunction>