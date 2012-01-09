<cfadmin
		action="getDatasources"
		type="web"
		password="#arguments.cfAdminPassword#"
		returnVariable="datasources">

<cfloop query="datasources">
	<cfif datasources.name eq arguments.dataSourceProperties.name>
		<cfset sDsn      = datasources.dsn>
		<cfset sUsername = datasources.username>
		<cfset sPassword = datasources.password>
		<cfset sCustom = datasources.customSettings>
		<cfbreak>
	</cfif>
</cfloop>

<cfadmin action="updateDatasource" 
		type="web"
		password="#arguments.cfAdminPassword#"
		classname="#arguments.dataSourceProperties.class#"
		dsn="#arguments.dataSourceProperties.url#"
		name="#arguments.datasourceName#"
		newname="#arguments.datasourceName#"
		host="#arguments.dataSourceProperties.host#"
		database="#arguments.dataSourceProperties.database#"
		port="#arguments.dataSourceProperties.port#"
		dbusername="#sUsername#"
		dbpassword="#sPassword#"
		custom="#sCustom#"
		remoteClients="[]">
