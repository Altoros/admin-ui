function ServicePlansTab(id) 
{
    Tab.call(this, id, Constants.URL__SERVICE_PLANS_VIEW_MODEL);
}

ServicePlansTab.prototype             = new Tab();

ServicePlansTab.prototype.constructor = ServicePlansTab;

ServicePlansTab.prototype.initialize = function()
{
    Tab.prototype.initialize.call(this);

    this.servicePlansOrganizationsTable = Table.createTable("ServicePlansOrganizations", this.getOrganizationsColumns(), [[0, "asc"]], null, null, null, null);
};

ServicePlansTab.prototype.getInitialSort = function() 
{
    return [[3, "asc"]];
};

ServicePlansTab.prototype.getColumns = function() 
{
    return [
                {
                    "sTitle":    "&nbsp;",
                    "sWidth":    "2px",
                    "sClass":    "cellCenterAlign",
                    "bSortable": false,
                    "mRender":   function(value, type, item) 
                    {
                        return "<input type='checkbox' name='" + escape(item[3]) + "' value='" + value + "' onclick='ServicePlansTab.prototype.checkboxClickHandler(event)'></input>";
                    }
                },
                {
                    "sTitle": "Name",
                    "sWidth": "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle": "GUID",
                    "sWidth": "200px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Target",
                    "sWidth":  "200px",
                    "mRender": Format.formatTarget
                },
                {
                    "sTitle": "Created",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Active",
                    "sWidth":  "70px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Public",
                    "sWidth":  "70px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Free",
                    "sWidth":  "70px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Visible Organizations",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle":  "Service Instances",
                    "sWidth":  "80px",
                    "sClass":  "cellRightAlign",
                    "mRender": Format.FormatNumber
                },
                {
                    "sTitle": "Provider",
                    "sWidth": "100px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle":  "Label",
                    "sWidth":  "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle": "GUID",
                    "sWidth": "200px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Version",
                    "sWidth": "100px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Created",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Active",
                    "sWidth": "80px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Bindable",
                    "sWidth":  "80px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Name",
                    "sWidth":  "200px",
                    "mRender": Format.formatServiceString
                },
                {
                    "sTitle":  "GUID",
                    "sWidth":  "200px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle":  "Created",
                    "sWidth":  "170px",
                    "mRender": Format.formatString
                },
                {
                    "sTitle": "Updated",
                    "sWidth": "170px",
                    "mRender": Format.formatString
                }
            ];
};

ServicePlansTab.prototype.getOrganizationsColumns = function()
{
    return [
               {
                   "sTitle":  "Organization",
                   "sWidth":  "200px",
                   "mRender": function(name, type, item)
                   {
                       if (Format.doFormatting(type))
                       {
                           var cleansedName = Format.formatStringCleansed(name);
                           return "<a class='tableLink' onclick='AdminUI.showOrganizations(\"" + 
                                  cleansedName + 
                                  "\")'>" + 
                                  cleansedName + 
                                  "</a><img onclick='ServicePlansTab.prototype.displayOrganizationDetail(event, \"" + 
                                  item[2] + 
                                  "\");' src='images/details.gif' style='margin-left: 5px; vertical-align: middle;' height=14>";
                       }

                       return name;
                   }
               },
               {
                   "sTitle":  "Created",
                   "sWidth":  "170px",
                   "mRender": Format.formatDateString
               },
           ];
};

ServicePlansTab.prototype.getActions = function() 
{
    return [
               {
                   text: " Public ",
                   click: $.proxy(function() 
                   {
                       this.changeVisibility("public");
                   }, 
                   this)
               },
               {
                   text: "Private",
                   click: $.proxy(function() 
                   {
                       this.changeVisibility("private");
                   }, 
                   this)
               }
           ];
};

ServicePlansTab.prototype.hideDetails = function()
{
    Tab.prototype.hideDetails.call(this);
    
    $("#ServicePlansOrganizationsTableContainer").hide();
};

ServicePlansTab.prototype.linkClickHandler = function(service_plan_name) 
{
    AdminUI.showServiceInstances(service_plan_name);
};

ServicePlansTab.prototype.clickHandler = function()
{
    this.itemClicked(-1, 2);
};

ServicePlansTab.prototype.showDetails = function(table, objects, row)
{
    var service                                 = objects.service;
    var serviceBroker                           = objects.serviceBroker;
    var servicePlan                             = objects.servicePlan;
    var servicePlanVisibilitiesAndOrganizations = objects.servicePlanVisibilitiesAndOrganizations;

    if (servicePlan != null)
    {
        this.addJSONDetailsLinkRow(table, "Service Plan Name", Format.formatString(servicePlan.name), objects, true);
        this.addPropertyRow(table, "Service Plan GUID", Format.formatString(servicePlan.guid));
        this.addPropertyRow(table, "Service Plan Created", Format.formatDateString(servicePlan.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Plan Updated", Format.formatDateString, servicePlan.updated_at);
        this.addPropertyRow(table, "Service Plan Active", Format.formatBoolean(servicePlan.active));
        this.addPropertyRow(table, "Service Plan Public", Format.formatBoolean(servicePlan.public));
        this.addPropertyRow(table, "Service Plan Free", Format.formatBoolean(servicePlan.free));
        this.addPropertyRow(table, "Service Plan Description", Format.formatString(servicePlan.description));
        
        if (servicePlan.extra != null)
        {
            var servicePlanExtra = jQuery.parseJSON(servicePlan.extra);
            
            this.addRowIfValue(this.addPropertyRow, table, "Service Plan Display Name", Format.formatString, servicePlanExtra.displayName);
            
            if (servicePlanExtra.bullets != null)
            {
                var bullets = servicePlanExtra.bullets;
                
                for (var bulletIndex = 0; bulletIndex < bullets.length; bulletIndex++)
                {
                    this.addPropertyRow(table, "Service Plan Bullet", Format.formatString(bullets[bulletIndex]));
                }
            }
        }
        
        var serviceInstancesLink = document.createElement("a");
        $(serviceInstancesLink).attr("href", "");
        $(serviceInstancesLink).addClass("tableLink");
        $(serviceInstancesLink).html(Format.formatNumber(row[10]));
        $(serviceInstancesLink).click(function()
        {
            AdminUI.showServiceInstances(row[3]);

            return false;
        });
        this.addRow(table, "Service Instances", serviceInstancesLink);
    }
    
    if (serviceBroker != null)
    {
        this.addPropertyRow(table, "Service Broker Name", Format.formatString(serviceBroker.name));
        this.addPropertyRow(table, "Service Broker GUID", Format.formatString(serviceBroker.guid));
        this.addPropertyRow(table, "Service Broker Created", Format.formatDateString(serviceBroker.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Broker Updated", Format.formatDateString, serviceBroker.updated_at);
    }

    if (service != null)
    {
        this.addRowIfValue(this.addPropertyRow, table, "Service Provider", Format.formatString, service.provider);
        this.addPropertyRow(table, "Service Label", Format.formatString(service.label));
        this.addPropertyRow(table, "Service GUID", Format.formatString(service.guid));
        this.addRowIfValue(this.addPropertyRow, table, "Service Version", Format.formatString, service.version);
        this.addPropertyRow(table, "Service Created", Format.formatDateString(service.created_at));
        this.addRowIfValue(this.addPropertyRow, table, "Service Updated", Format.formatDateString, service.updated_at);
        this.addPropertyRow(table, "Service Active", Format.formatBoolean(service.active));
        this.addPropertyRow(table, "Service Bindable", Format.formatString(service.bindable));
        this.addPropertyRow(table, "Service Description", Format.formatString(service.description));
        
        if (service.tags != null)
        {
            var serviceTags = jQuery.parseJSON(service.tags);
            
            if (serviceTags != null && serviceTags.length > 0)
            {
                for (var serviceTagIndex = 0; serviceTagIndex < serviceTags.length; serviceTagIndex++)
                {
                    var serviceTag = serviceTags[serviceTagIndex];
    
                    this.addPropertyRow(table, "Service Tag", Format.formatString(serviceTag));
                }
            }
        }
        
        // Documentation URL for v1 service
        if (service.documentation_url != null)
        {
            var documentationLink = document.createElement("a");
            $(documentationLink).attr("target", "_blank");
            $(documentationLink).attr("href", service.documentation_url);
            $(documentationLink).addClass("tableLink");
            $(documentationLink).html(service.documentation_url);

            this.addRow(table, "Service Documentation URL", documentationLink);
        }

        // Info URL for v1 service
        if (service.info_url != null)
        {
            var infoLink = document.createElement("a");
            $(infoLink).attr("target", "_blank");
            $(infoLink).attr("href", service.info_url);
            $(infoLink).addClass("tableLink");
            $(infoLink).html(service.info_url);

            this.addRow(table, "Service Info URL", infoLink);
        }

        if (service.extra != null)
        {
            var serviceExtra = jQuery.parseJSON(service.extra);
            this.addRowIfValue(this.addPropertyRow, table, "Service Display Name", Format.formatString, serviceExtra.displayName);
            this.addRowIfValue(this.addPropertyRow, table, "Service Provider Display Name", Format.formatString, serviceExtra.providerDisplayName);
            this.addRowIfValue(this.addFormattableTextRow, table, "Service Icon", Format.formatIconImage, serviceExtra.imageUrl, "service icon", "flot:left;");
            this.addRowIfValue(this.addPropertyRow, table, "Service Long Description", Format.formatString, serviceExtra.longDescription);
            
            if (serviceExtra.documentationUrl != null)
            {
                var documentationLink = document.createElement("a");
                $(documentationLink).attr("target", "_blank");
                $(documentationLink).attr("href", serviceExtra.documentationUrl);
                $(documentationLink).addClass("tableLink");
                $(documentationLink).html(serviceExtra.documentationUrl);

                this.addRow(table, "Service Documentation URL", documentationLink);
            }
            
            if (serviceExtra.supportUrl != null)
            {
                var supportLink = document.createElement("a");
                $(supportLink).attr("target", "_blank");
                $(supportLink).attr("href", serviceExtra.supportUrl);
                $(supportLink).addClass("tableLink");
                $(supportLink).html(serviceExtra.supportUrl);

                this.addRow(table, "Service Support URL", supportLink);
            }
        }
    }
    
    if (servicePlanVisibilitiesAndOrganizations != null && servicePlanVisibilitiesAndOrganizations.length > 0)
    {
        // Have to show the table prior to populating for its sizing to work correctly.
        $("#ServicePlansOrganizationsTableContainer").show();

        var servicePlansOrganizationsTableData = [];

        for (var servicePlanVisibilityAndOrganizationIndex = 0; servicePlanVisibilityAndOrganizationIndex < servicePlanVisibilitiesAndOrganizations.length; servicePlanVisibilityAndOrganizationIndex++)
        {
            var servicePlanVisibilityAndOrganization = servicePlanVisibilitiesAndOrganizations[servicePlanVisibilityAndOrganizationIndex];
            var organization                         = servicePlanVisibilityAndOrganization.organization;
            var servicePlanVisibility                = servicePlanVisibilityAndOrganization.servicePlanVisibility;

            var organizationRow = [];

            organizationRow.push(organization.name);
            organizationRow.push(servicePlanVisibility.created_at);

            // Need both the index and the actual object in the table
            organizationRow.push(servicePlanVisibilityAndOrganizationIndex);
            organizationRow.push(servicePlanVisibilityAndOrganization);

            servicePlansOrganizationsTableData.push(organizationRow);
        }

        this.servicePlansOrganizationsTable.fnClearTable();
        this.servicePlansOrganizationsTable.fnAddData(servicePlansOrganizationsTableData);
    }
};

ServicePlansTab.prototype.checkboxClickHandler = function(event)
{
    event.stopPropagation();
};

ServicePlansTab.prototype.changeVisibility = function(targetedVisibility) 
{
    if (!targetedVisibility || 
        (targetedVisibility != Constants.STATUS__PUBLIC && 
         targetedVisibility != Constants.STATUS__PRIVATE ) ) 
    {
        return;
    }

    var servicePlans = this.getSelectedServicePlans();

    if (!servicePlans || servicePlans.length == 0) 
    {
        return;
    }

    var body = (targetedVisibility === Constants.STATUS__PUBLIC) ? '{"public": true}': '{"public": false }';
    
    var processed = 0;
    
    var errorServicePlans = [];
    
    AdminUI.showModalDialogProgress("Managing Service Plans");

    for (var servicePlanIndex = 0; servicePlanIndex < servicePlans.length; servicePlanIndex++) 
    {
        var servicePlan = servicePlans[servicePlanIndex];
        
        var deferred = $.ajax({
                                  type:              "PUT",
                                  url:               Constants.URL__SERVICE_PLANS + "/" + servicePlan.guid,
                                  contentType:       "application/json; charset=utf-8",
                                  data:              body,
                                  // Need service plan target inside the fail method
                                  servicePlanTarget: servicePlan.target
                              });
        
        deferred.fail(function(xhr, status, error) 
        {
            errorServicePlans.push({
                                       label: this.servicePlanTarget,
                                       xhr:   xhr
                                   });
        });
        
        deferred.always(function(xhr, status, error)
        {
            processed++;
            
            if (processed == servicePlans.length)
            {
                if (errorServicePlans.length > 0) 
                {
                    AdminUI.showModalDialogErrorTable(errorServicePlans);
                } 
                else
                {
                    AdminUI.showModalDialogSuccess();
                }

                AdminUI.refresh();
            }
        });
    }
};

ServicePlansTab.prototype.getSelectedServicePlans = function() 
{
    var checkedRows = $("input:checked", this.table.fnGetNodes());

    if (checkedRows.length == 0)
    {
        AdminUI.showModalDialogError("Please select at least one row!");
        
        return null;
    }

    var servicePlans = [];

    for (var checkedIndex = 0; checkedIndex < checkedRows.length; checkedIndex++)
    {
        var checkedRow = checkedRows[checkedIndex];
        
        servicePlans.push({
                              target: unescape(checkedRow.name),
                              guid:   checkedRow.value
                          });
    }

    return servicePlans;
};

ServicePlansTab.prototype.displayOrganizationDetail = function(event, rowIndex)
{
    var row = $("#ServicePlansOrganizationsTable").dataTable().fnGetData(rowIndex);

    var organization = row[3];

    var json = JSON.stringify(organization, null, 4);

    var page = window.open("", "_blank", "fullscreen=yes,menubar=no,scrollbars=yes,titlebar=no,toolbar=no");

    if (page != null)
    {
        page.document.write("<pre>" + json + "</pre>");
        page.document.close();
    }

    event.stopPropagation();

    return false;
};
