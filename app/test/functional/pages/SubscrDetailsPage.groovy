package pages

import org.openqa.selenium.Keys

/**
 * Created by ioannis on 03/06/2014.
 */
class SubscrDetailsPage extends AbstractDetails {
    static url = "/demo/subscriptionDetails/show/*"
    static at = { browser.page.title.endsWith("- Current Subscriptions") ||
            browser.page.title.startsWith ("KB+ Subscription")  };
    static content = {
        newSubscription { ref ->
            $("a", text: "New Subscription (Empty)").click()
            $("input", name: "newEmptySubName").value(ref)
            $("input", value: "Create").click()
        }
        licenceCategory {
            $("span", 'data-name': "licenceCategory").click()
            $("button.editable-submit").click()
        }
        viewSubscription { ref ->
            $("a",text:ref).click()
        }

        addLicence{ ref->
            $("span", 'data-name': "owner").click()
            waitFor{$("form.editableform")}
            $("select.input-medium").value(ref)
            $("button.editable-submit").click()
        }
        linkPackage { ref,entitlements ->
            $("a",text:"Link Package").click()
            def td= $("a",text:ref).parent().siblings().next()
            if(entitlements){
                withConfirm{td.find("a",text:"Link (with Entitlements)").click()}
            }else{
                withConfirm{td.find("a",text:"Link (no Entitlements)").click()}

            }
        }
        addEntitlements{
            $("a",text:"Add Entitlements").click()
            $("input",name:"chkall").click()
            $("input",value:"Add Selected Entitlements").click()
        }
        csvExport {
            $("a",text:"Exports").click()
            $("a",text:"CSV Export").click()
        }
        csvExportNoHeader {
            $("a",text:"Exports").click()
            $("a",text:"CSV Export (No header)").click()
        }
        jsonExport{
            $("a",text:"Exports").click()
            $("a",text:"JSON").click()
        }
        xmlExport{
            $("a",text:"Exports").click()
            $("a",text:"XML").click()
        }
        OCLCExport{
            $("a",text:"Exports").click()
            $("a",text:"OCLC Resolver").click()
        }
        serialsExport{
            $("a",text:"Exports").click()
            $("a",text:"Serials Solutions Resolver").click()
        }
        sfxExport{
            $("a",text:"Exports").click()
            $("a",text:"SFX Resolver").click()
        }
        kbplusExport{
            $("a",text:"Exports").click()
            $("a",text:"KBPlus Import Format").click()

        }
        deleteSubscription{ref ->
            String subURL = $("a",text:ref).@href
            String subId = subURL.substring(subURL.lastIndexOf("/")+1,subURL.length())
            $("input",type:"radio",name:"basesubscription").value(subId)
            $("input.btn",value:"Delete Selected").click()
        }
    }
}
