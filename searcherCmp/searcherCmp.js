import { LightningElement, track, wire } from 'lwc';
import getSearchableObjects from '@salesforce/apex/CustomSearchController.getSearchableObjects';
import getFieldsMeta from '@salesforce/apex/CustomSearchController.getFieldsMeta';
import Website_FIELD from '@salesforce/schema/Account.Website';

export default class SearcherCmp extends LightningElement {
    ALL_OBJECTS = 'All Data';
    ALL_FILTERS = 'Select';
    selectedSobjectName = 'Account';
    @track fieldTypeText = false;
    @track fieldTypeBool = false;
    @track fieldTypeList = false;
    @track fieldTypeRef = false;
    @track allFilters = [];
    @track allFields = [];
    @track allFieldsMeta = [];
    @track allSobjects = [];
    @track objRecords = [];
    
    connectedCallback() {        
        //Get All objects for search operation
        getSearchableObjects().then(response => {
            var sObjList = [];
            for(let i=0; i<response.length; i++){
                let dataArray = {};
                dataArray.id = response[i];
                dataArray.name = response[i];
                sObjList.push(dataArray);                
            }
            this.allSobjects = sObjList;
        }).catch(error => {
            console.error(error);
        });
    }

    handleObjectChange(event) {
        this.objRecords = [];
        this.objRecords.push({key : Math.random().toString(36).substring(2, 15)});

        this.selectedSobjectName = event.target.value;

        getFieldsMeta({sObjectName:this.selectedSobjectName})
        .then((response)=>{
            this.allFields = [];
            this.allFieldsMeta = response;
            for (let key in response) {
                let fieldLabel = response[key].split("*");
                this.allFields.push({id:key, name:fieldLabel[0]});
            }
        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;
        });s
    }

    removeRow(event) {
        const indexPos = event.currentTarget.name;
        let remList = [];
        remList = this.objRecords;
        remList.splice(indexPos,1);
        this.objRecords = remList;
    }

    addRow(event) {
        const indexPos = event.currentTarget.name;
        console.log(indexPos);
        this.objRecords.splice(indexPos+1, 0, {key : Math.random().toString(36).substring(2, 15)});
    }

    handleFieldChange(event) {
        var selectedField = event.target.value;
        var textOperators = ['Equals', 'Contains', 'Starts With', 'Ends With', 'Not Equal'];
 
        if(this.allFieldsMeta.hasOwnProperty(selectedField)) {
            var fieldType = this.allFieldsMeta[selectedField].split("*");
            //console.log('Ok1'+ fieldType);
            if(fieldType[1]=='ID' || fieldType[1]=='STRING') {
                textOperators.forEach(opVal => {
                    console.log(opVal);
                    this.allFilters.push({id:opVal, name:opVal});
                });
                fieldTypeText = true;
                //console.log('Ok'+this.allFilters);
            }
            
            var ar2 = {
                ID:"",
                STRING: "Text", 
                PICKLIST: "Dropdown", 
                REFERENCE: "Lookup",
            };
            //ID, STRING, PICKLIST, REFERENCE, TEXTAREA, PHONE, ADDRESS, URL, CURRENCY, DATETIME, BOOLEAN, DOUBLE, INTEGER, DATE
        }

        console.log(selectedField);
        console.log(this.allFieldsMeta[selectedField]);
        console.log('---');
    }
}