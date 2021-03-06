<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/document_library/init.jsp" %>

<%
long repositoryId = ParamUtil.getLong(request, "repositoryId");

if (repositoryId == 0) {
	repositoryId = scopeGroupId;
}

long searchRepositoryId = ParamUtil.getLong(request, "searchRepositoryId");

if (searchRepositoryId == 0) {
	searchRepositoryId = scopeGroupId;
}

long folderId = ParamUtil.getLong(request, "folderId");

long searchFolderId = ParamUtil.getLong(request, "searchFolderId");

Folder folder = null;

if (searchFolderId > 0) {
	folder = DLAppServiceUtil.getFolder(searchFolderId);
}

List<Folder> mountFolders = DLAppServiceUtil.getMountFolders(scopeGroupId, DLFolderConstants.DEFAULT_PARENT_FOLDER_ID, QueryUtil.ALL_POS, QueryUtil.ALL_POS);

String keywords = ParamUtil.getString(request, "keywords");

boolean showRepositoryTabs = ParamUtil.getBoolean(request, "showRepositoryTabs");

EntriesChecker entriesChecker = new EntriesChecker(liferayPortletRequest, liferayPortletResponse);

entriesChecker.setCssClass("entry-selector");
entriesChecker.setRememberCheckBoxStateURLRegex("^(?!.*" + liferayPortletResponse.getNamespace() + "redirect).*(folderId=" + String.valueOf(folderId) + ")");
%>

<aui:input name="repositoryId" type="hidden" value="<%= repositoryId %>" />
<aui:input name="searchRepositoryId" type="hidden" value="<%= searchRepositoryId %>" />

<liferay-util:buffer
	var="searchResults"
>

	<%
	SearchContainer dlSearchContainer = dlAdminDisplayContext.getSearchContainer();
	%>

	<div class="document-container" id="<portlet:namespace />entriesContainer">
		<liferay-ui:search-container
			emptyResultsMessage='<%= LanguageUtil.format(request, "no-documents-were-found-that-matched-the-keywords-x", keywords) %>'
			id="entries"
			searchContainer="<%= dlSearchContainer %>"
			total="<%= dlSearchContainer.getTotal() %>"
		>
			<liferay-ui:search-container-row
				className="Object"
				modelVar="result"
			>
				<%@ include file="/document_library/cast_result.jspf" %>

				<c:choose>
					<c:when test="<%= (fileEntry != null) && DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.VIEW) %>">

						<%
						FileVersion latestFileVersion = fileEntry.getFileVersion();

						if ((user.getUserId() == fileEntry.getUserId()) || permissionChecker.isContentReviewer(user.getCompanyId(), scopeGroupId) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE)) {
							latestFileVersion = fileEntry.getLatestFileVersion();
						}

						if ((dlSearchContainer.getRowChecker() == null) && (DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.DELETE) || DLFileEntryPermission.contains(permissionChecker, fileEntry, ActionKeys.UPDATE))) {
							dlSearchContainer.setRowChecker(entriesChecker);
						}

						String thumbnailSrc = DLUtil.getThumbnailSrc(fileEntry, latestFileVersion, themeDisplay);

						DLViewFileVersionDisplayContext dlViewFileVersionDisplayContext = dlDisplayContextProvider.getDLViewFileVersionDisplayContext(request, response, fileEntry.getFileVersion());

						row.setPrimaryKey(String.valueOf(fileEntry.getFileEntryId()));
						%>

						<c:choose>
							<c:when test="<%= Validator.isNotNull(thumbnailSrc) %>">
								<liferay-ui:search-container-column-image
									src="<%= thumbnailSrc %>"
									toggleRowChecker="<%= true %>"
								/>
							</c:when>
							<c:when test="<%= Validator.isNotNull(latestFileVersion.getExtension()) %>">
								<liferay-ui:search-container-column-text>
									<div class="sticker sticker-secondary <%= dlViewFileVersionDisplayContext.getCssClassFileMimeType() %>">
										<%= StringUtil.shorten(StringUtil.upperCase(latestFileVersion.getExtension()), 3, StringPool.BLANK) %>
									</div>
								</liferay-ui:search-container-column-text>
							</c:when>
							<c:otherwise>
								<liferay-ui:search-container-column-icon
									icon="documents-and-media"
									toggleRowChecker="<%= true %>"
								/>
							</c:otherwise>
						</c:choose>

						<liferay-ui:search-container-column-jsp
							colspan="<%= 2 %>"
							path="/document_library/view_file_entry_descriptive.jsp"
						/>

						<liferay-ui:search-container-column-jsp
							path="/document_library/file_entry_action.jsp"
						/>
					</c:when>
					<c:when test="<%= (curFolder != null) && DLFolderPermission.contains(permissionChecker, curFolder, ActionKeys.VIEW) %>">

						<%
						if ((dlSearchContainer.getRowChecker() == null) && (DLFolderPermission.contains(permissionChecker, curFolder, ActionKeys.DELETE) || DLFolderPermission.contains(permissionChecker, curFolder, ActionKeys.UPDATE))) {
							dlSearchContainer.setRowChecker(entriesChecker);
						}

						row.setPrimaryKey(String.valueOf(curFolder.getPrimaryKey()));
						%>

						<liferay-ui:search-container-column-icon
							icon='<%= curFolder.isMountPoint() ? "repository" : "folder" %>'
							toggleRowChecker="<%= true %>"
						/>

						<liferay-ui:search-container-column-jsp
							colspan="<%= 2 %>"
							path="/document_library/view_folder_descriptive.jsp"
						/>

						<liferay-ui:search-container-column-jsp
							path="/document_library/folder_action.jsp"
						/>
					</c:when>
					<c:otherwise>
						<div style="float: left; margin: 100px 10px 0;">
							<i class="icon-ban-circle"></i>
						</div>
					</c:otherwise>
				</c:choose>
			</liferay-ui:search-container-row>

			<liferay-ui:search-iterator
				displayStyle="descriptive"
				markupView="lexicon"
				searchContainer="<%= dlSearchContainer %>"
			/>
		</liferay-ui:search-container>
	</div>
</liferay-util:buffer>

<c:choose>
	<c:when test="<%= showRepositoryTabs %>">

		<%
		PortletURL searchRepositoryURL = liferayPortletResponse.createRenderURL();

		searchRepositoryURL.setParameter("mvcRenderCommandName", "/document_library/search");
		searchRepositoryURL.setParameter("repositoryId", String.valueOf(scopeGroupId));
		searchRepositoryURL.setParameter("searchRepositoryId", String.valueOf(scopeGroupId));
		searchRepositoryURL.setParameter("keywords", keywords);
		searchRepositoryURL.setParameter("showRepositoryTabs", Boolean.TRUE.toString());
		searchRepositoryURL.setParameter("showSearchInfo", Boolean.TRUE.toString());

		String[] tabsUrls = {searchRepositoryURL.toString()};

		String selectedTab = LanguageUtil.get(request, "local");

		for (Folder mountFolder : mountFolders) {
			if (mountFolder.getRepositoryId() == searchRepositoryId) {
				selectedTab = HtmlUtil.escape(mountFolder.getName());
			}

			searchRepositoryURL.setParameter("repositoryId", String.valueOf(mountFolder.getRepositoryId()));
			searchRepositoryURL.setParameter("searchRepositoryId", String.valueOf(mountFolder.getRepositoryId()));

			tabsUrls = ArrayUtil.append(tabsUrls, searchRepositoryURL.toString());
		}
		%>

		<div class="search-results-container" id="<portlet:namespace />searchResultsContainer">
			<liferay-ui:tabs
				names='<%= LanguageUtil.get(request, "local") + "," + HtmlUtil.escape(ListUtil.toString(mountFolders, "name")) %>'
				refresh="<%= false %>"
				urls="<%= tabsUrls %>"
				value="<%= selectedTab %>"
			>
				<liferay-ui:section>
					<div class="local-search-results" data-repositoryId="<%= scopeGroupId %>" <%= scopeGroupId == searchRepositoryId ? "data-searchProcessed" : "" %> id="<portlet:namespace />searchResultsContainer<%= scopeGroupId %>">
						<c:choose>
							<c:when test="<%= scopeGroupId == searchRepositoryId %>">
								<%= searchResults %>
							</c:when>
							<c:otherwise>
								<div class="alert alert-info">
									<liferay-ui:message key="searching,-please-wait" />
								</div>

								<div class="loading-animation"></div>
							</c:otherwise>
						</c:choose>
					</div>
				</liferay-ui:section>

				<%
				for (Folder mountFolder : mountFolders) {
				%>

					<liferay-ui:section>
						<div data-repositoryId="<%= mountFolder.getRepositoryId() %>" <%= mountFolder.getRepositoryId() == searchRepositoryId ? "data-searchProcessed" : "" %> id="<portlet:namespace />searchResultsContainer<%= mountFolder.getRepositoryId() %>">
							<c:choose>
								<c:when test="<%= mountFolder.getRepositoryId() == searchRepositoryId %>">
									<%= searchResults %>
								</c:when>
								<c:otherwise>
									<div class="alert alert-info">
										<liferay-ui:message key="searching,-please-wait" />
									</div>

									<div class="loading-animation"></div>
								</c:otherwise>
							</c:choose>
						</div>
					</liferay-ui:section>

				<%
				}
				%>

			</liferay-ui:tabs>
		</div>
	</c:when>
	<c:otherwise>
		<div class="repository-search-results" data-repositoryId="<%= searchRepositoryId %>" id="<%= liferayPortletResponse.getNamespace() + "searchResultsContainer" + searchRepositoryId %>">
			<%= searchResults %>
		</div>
	</c:otherwise>
</c:choose>

<%
request.setAttribute("view.jsp-folderId", String.valueOf(folderId));
%>