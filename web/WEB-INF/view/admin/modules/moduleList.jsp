<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="Manage Modules" otherwise="/login.htm" redirect="/admin/modules/module.list" />
	
<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>
<openmrs:htmlInclude file="/scripts/jquery/dataTables/css/dataTables.css" />
<openmrs:htmlInclude file="/scripts/jquery/dataTables/js/jquery.dataTables.min.js" />
<openmrs:htmlInclude file="/scripts/jquery-ui/js/jquery-ui-1.7.2.custom.min.js" />
<openmrs:htmlInclude file="/scripts/jquery-ui/css/redmond/jquery-ui-1.7.2.custom.css" />
<openmrs:htmlInclude file="/dwr/util.js" />
<openmrs:htmlInclude file="/dwr/interface/DWRUserService.js" />
<openmrs:htmlInclude file="/scripts/jconfirm/js/jconfirm.js" />
<openmrs:htmlInclude file="/scripts/jconfirm/css/jconfirm.css" /> 
<openmrs:confirmDialog id="Restart_Confirm" messageCode="Module.restartConfirmation" button1="general.yes" button2="general.no" suppress="moduleadmin.moduleRestart" suppressMessageCode="general.dontShowMessage" />
<openmrs:confirmDialog id="Unload_Confirm" messageCode="Module.unloadWarning" button1="general.yes" button2="general.no" suppress="moduleadmin.moduleUnload" suppressMessageCode="general.dontShowMessage" />
<openmrs:confirmDialog id="Start_Confirm" messageCode="Module.startWarning" button1="general.yes" button2="general.no" suppress="moduleadmin.moduleStart" suppressMessageCode="general.dontShowMessage" />
<openmrs:confirmDialog id="Stop_Confirm" messageCode="Module.stopWarning" button1="general.yes" button2="general.no" suppress="moduleadmin.moduleStop" suppressMessageCode="general.dontShowMessage" />
<script type="text/javascript">
	var oTable;
	
	$j(document).ready(function() {
		$j('#addUpgradePopup').dialog({
			autoOpen: false,
			modal: true,
			title: '<spring:message code="Module.addOrUpgrade" javaScriptEscape="true"/>',
			width: '90%'
		});		
				
		$j('#addUpgradeButton').click(function() {
			$j('#addUpgradePopup').dialog('open');
		});		
		
		$j('#moduleAddForm input[name=moduleFile]').change(function(){
			var fileName = $j(this).val();
			var disabled = fileName == '' ? 'disabled' : '';			
			$j('#moduleAddForm input[name=uploadFile]').attr('disabled',disabled);
		});
		
		$j('#moduleAddForm input[name=uploadFile]').click(function(){			
			$j('#moduleAddForm input[name=uploadFile]').attr('disabled','disabled');
			$j('#moduleAddForm').submit(); 
		});		

		$j('.errorDetailsButton').click(function() {
			var detailsNum = $j(this).attr('id').substring(18); // strip 'errorDetailsButton'
			$j('#errorDetails' + detailsNum).dialog('open');
		});

		oTable = $j('#findModuleTable').dataTable({
			"aaData":[
						<c:forEach var="module" items="${repoList}" varStatus="varStatus">
							[ "${module.downloadURL}", "${module.name}", "${module.version}", "${module.author}", "${module.description}" ] <c:if test="${!varStatus.last}">,</c:if> 
						</c:forEach>
					 ],
			"aoColumns": [ { "sName": "Action", "bSortable": false,
					         "fnRender": function ( oObj ) {
									var downloadURL = oObj.aData[0];
									if(downloadURL != 'Installed'){
										return '<form action="module.list" method="post"><input type="hidden" name="download" value="true" /><input type="hidden" name="action" value="upload" /><input type="hidden" name="downloadURL" value="' + downloadURL + '" /><input type="submit" value="<spring:message code="Module.install" />" /></form>';
									}else{
										return '<form><input type="submit" disabled="true" value="<spring:message code="Module.installed" />" /></form>';
									}
								}
							},
							{ "sName": "Name" },
							{ "sName": "Version" },
							{ "sName": "Author" },
							{ "sName": "Description" }
			  			 ]			
		});
	});
			
	//Javascript Function to show Restart Confirmation 
	function confirmRestart(id){
		jConfirm.dialog(id, 
		function(){			
			$j('#openmrsModulesForm').submit();
			$j('#openmrsModulesForm #restartMessage').html('<spring:message code="Module.openmrsRestaring"/>');
		},
		function(){			
		},
		null);		
		
		return false;
	}
	
	//Javascript Function to show confirmation for module actions 
	function confirmation(id, buttonId, action){		
		var index = buttonId.substring(action.length); // strip action
		var formId = '#controlform'+index;		
		jConfirm.dialog(id,
		function(){ 
			$j(formId).append("<input type='hidden' name='action' value='" + action + "' />");			
			$j(formId).submit();
		},
		function(){
		},
		null);		
		
		return false;
	}
	
	
</script>

<h2><spring:message code="Module.header" /></h2>

<c:if test="${showUpgradeConfirm == 'true'}">
	<div style="width: 100%;background-color: #87CEFA">
		<form name="upgradeConfirmForm" method="post">
			<div style="margin: auto;width: 70%">
				<div style="clear:both">&nbsp;</div>
				<spring:message code="Module.upgradeWarning" arguments="${moduleName}"/> <input type="submit" onclick="document.upgradeConfirmForm.action.value = 'moduleupgrade.yes';return true" value="<spring:message code="general.yes"/>"/> <input type="submit" onclick="document.upgradeConfirmForm.action.value = 'moduleupgrade.no';return true" value="<spring:message code="general.no"/>"/>
				<br>
				<p style="margin: auto;width: 70%"><input type="checkbox" name="dontShowMessage" value="true"> <spring:message code="general.dontShowMessage"/></p>			
				<input type="hidden" name="action" value="confirmation"/>
				<div style="clear:both">&nbsp;</div>
			</div>
		</form>
	</div>
	<div style="clear:both">&nbsp;</div>
</c:if>

<c:if test="${hasPendingActions == 'true'}">
	<div style="width: 100%;background-color: #FFAEB9">
		<form id="openmrsModulesForm" method="post">
			<div style="margin: auto;width: 70%">
				<div style="clear:both">&nbsp;</div>
				<div id="restartMessage">
					<spring:message code="Module.restartWarning"/> <input <c:if test="${showUpgradeConfirm == 'true'}">disabled="true"</c:if> type="button" value="<spring:message code="Module.restartOpenmrs"/>" onclick="return confirmRestart('Restart_Confirm');"/>
					<input type="hidden" name="action" value="restartModules"/>					
				</div>
				<div style="clear:both">&nbsp;</div>
			</div> 
		</form>		
	</div>
	<div style="clear:both">&nbsp;</div>
</c:if>

<c:choose>
	<c:when test="${allowAdmin == 'true'}">
		<div id="buttonPanel">
			<div style="float:left">
				<input type="button" id="addUpgradeButton" value="<spring:message code="Module.addOrUpgrade" javaScriptEscape="true"/>"/>
				<div id="addUpgradePopup">
					<b class="boxHeader"><spring:message code="Module.addOrUpgrade"/></b>
					<div class="box">
						<form id="moduleAddForm" action="module.list" method="post" enctype="multipart/form-data">
							<input type="file" name="moduleFile" size="40" <c:if test="${allowAdmin!='true'}">disabled="disabled"</c:if> />
							<input type="hidden" name="action" value="upload"/>
							<input type="submit" name="uploadFile" disabled="true" value='<spring:message code="Module.upload"/>'/>
						</form>
					</div>
					<br/>
								
					<div id="findModule">						
						<b class="boxHeader"><spring:message code="Module.findAndDownload" /></b>
						<div class="box">
							<c:if test="${moduleRepositoryCacheExpired == 'true'}">
								<div style="width: 100%;background-color: #FFAEB9">
									<form name="updateModuleRepository" method="post">
										<div style="margin: auto;width: 70%">											
											<spring:message code="Module.cacheExpired" /> <input type="submit" value="Update" />
											<input type="hidden" name="action" value="updateCache"/>											
										</div>
									</form>		
								</div>								
							</c:if>
							<table id="findModuleTable" cellpadding="5" cellspacing="0" style="width: 100%">
					    		<thead>
					       			<tr>
										<th><spring:message code="general.action"/></th>
										<th><spring:message code="general.name"/></th>
										<th><spring:message code="general.version"/></th>
										<th><spring:message code="general.author"/></th>
										<th><spring:message code="general.description"/></th>
					       			</tr>
					   			</thead>
					   			<tbody>
					    		</tbody>
							</table>
						</div>
					</div>
					<br/>
				</div>
			</div>
			<div style="float:left">
				<form method="post"><input type="submit" value='<spring:message code="Module.checkForUpdates"/>'/></form>				
			</div>
			<div style="clear:both">&nbsp;</div>
		</div>	
	</c:when>
	<c:otherwise>
		${disallowUploads}
	</c:otherwise>
</c:choose>

<c:forEach var="module" items="${moduleList}" varStatus="varStatus">
	<c:if test="${varStatus.first}">
		<b class="boxHeader"><spring:message code="Module.manage" /></b>
		<div class="box" id="moduleListing">
			<table cellpadding="5" cellspacing="0">
				<thead>
					<tr>
						<c:if test="${allowAdmin=='true'}">
							<th colspan="2"><spring:message code="general.action"/></th>
						</c:if>
						<th><spring:message code="general.name"/></th>
						<th><spring:message code="general.version"/></th>
						<th><spring:message code="general.author"/></th>
						<th><spring:message code="general.description"/></th>
						<th></th>
						<th></th>
					</tr>
				</thead>
				<tbody>
	</c:if>
			
				<form id="controlform${varStatus.index}" method="post">					
					<input type="hidden" name="moduleId" value="${module.moduleId}" />
					<tr class='${varStatus.index % 2 == 0 ? "oddRow" : "evenRow" }' id="${module.moduleId}">
						<c:choose>
							<c:when test="${allowAdmin=='true' && module.mandatory == false && module.coreModule == false && module.pendingAction.action == 'none'}">
								<td valign="top">
									<c:choose>
										<c:when test="${not module.started}">
											<input type="image" src="${pageContext.request.contextPath}/images/play.gif" name="start" id="start${varStatus.index}" onclick="return confirmation('Start_Confirm',this.id,this.name);" title="<spring:message code="Module.start.help"/>" alt="<spring:message code="Module.start"/>" />
										</c:when>
										<c:otherwise>
											<input type="image" src="${pageContext.request.contextPath}/images/stop.gif" name="stop" id="stop${varStatus.index}" onclick="return confirmation('Stop_Confirm',this.id,this.name);" title="<spring:message code="Module.stop.help"/>" alt="<spring:message code="Module.stop"/>" />
										</c:otherwise>
									</c:choose>
								</td>
								<td valign="top"><input type="image" src="${pageContext.request.contextPath}/images/trash.gif" name="unload" id="unload${varStatus.index}" onclick="return confirmation('Unload_Confirm',this.id,this.name);" title="<spring:message code="Module.unload.help"/>" title="<spring:message code="Module.unload"/>" alt="<spring:message code="Module.unload"/>" /></td>
							</c:when>
							<c:otherwise>
								<c:choose>
									<td valign="top">
										<c:when test="${ module.pendingAction.action != 'none' }">
											<img src="${pageContext.request.contextPath}/images/pending.png" title="<spring:message code="Module.pending.help"/>" alt="<spring:message code="Module.pending"/>" />
										</c:when>
										<c:otherwise>
											<img src="${pageContext.request.contextPath}/images/lock.gif" title="<spring:message code="Module.locked.help"/>" alt="<spring:message code="Module.locked"/>" />
										</c:otherwise>										
									</td>
								<td></td>
								</c:choose>
							</c:otherwise>
						</c:choose>
						<td valign="top">${module.name} <c:if test="${not module.started}"><b id="moduleNotStarted" style="white-space: nowrap">[<spring:message code="Module.notStarted"/>]</b></c:if></td>
						<td valign="top">${module.version}</td>
						<td valign="top">${module.author}</td>
						<td valign="top">
							<div>
								${fn:substring(fn:escapeXml(module.description),0, 200)}...
							<div>
							<c:if test="${module.pendingAction.action != 'none'}">
								<div style="color:red">
									<i>
									<spring:message code="Module.pendingAction" arguments="${module.pendingAction.action}" javaScriptEscape="true"/>
									</i>
								</div>
							</c:if>
						</td>
						<td valign="top"<c:if test="${module.startupErrorMessage != null}">class="error"</c:if> >
							<c:if test="${module.startupErrorMessage != null}">
								<span class="errorDetailsButton" id="errorDetailsButton${varStatus.index}">
									<spring:message code="Module.errorClickForDetails"/>
								</span>
								<div class="errorDetailsDialog" id="errorDetails${varStatus.index}">
									<pre style="margin: 0px;">${module.startupErrorMessage}</pre>
								</div>
								<script type="text/javascript">
									$j('#errorDetails${varStatus.index}').dialog({
										autoOpen: false,
										modal: true,
										title: '<spring:message code="Module.errorStarting" arguments="${module.name}" javaScriptEscape="true"/>',
										width: '90%'
									});
								</script>
							</c:if>
						</td>
						<td>
							<c:if test="${module.downloadURL != null && hasPendingActions == 'false'}">
								${module.updateVersion}
								<spring:message code="Module.updateAvailable" /> 
								<c:if test="${allowAdmin=='true'}">
									<input type="submit" name="action" value='<spring:message code="Module.installUpdate"/>'>
									<spring:message code="general.or"/>
								</c:if>
								<a href="${module.downloadURL}"><spring:message code="Module.downloadUpdate"/></a>
							</c:if>
						</td>
						<td>
							<c:if test="${module.configurable == 'true'}">
								<a href="moduleConfiguration.form?moduleId=${module.moduleId}"><spring:message code="Module.configure"/></a>
							</c:if>
						</td>
					</tr>
				</form>
				
	<c:if test="${varStatus.last}">
			</tbody>	
			</table>
		</div>

	</c:if>
	
</c:forEach>

<c:if test="${fn:length(moduleList) == 0}">
	<i> &nbsp; <spring:message code="Module.noLoadedModules"/></i><br/>
</c:if>

<br/>

<%@ include file="/WEB-INF/template/footer.jsp" %>