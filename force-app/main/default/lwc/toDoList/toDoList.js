import { LightningElement, wire} from 'lwc';
import userId from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getToDoList from '@salesforce/apex/ToDoListController.getToDoList';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToDoList extends NavigationMixin(LightningElement) {
    toDos;
    error;
    wiredToDosResult;

    // Wired method to retrieve To Do records.
    @wire(getToDoList, { userId: userId })
    wiredToDos(result) {
        this.wiredToDosResult = result;
        if (result.data) {
            this.toDos = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.toDos = undefined;
        }
    };

    // Navigate to standard new record creation modal for To Do object.
    navNewPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'To_Do__c',
                actionName: 'new'
            },
            state: {
                navigationLocation: 'RELATED_LIST' // Prevent redirect after creation
            }
        });
    }

    // Navigate to detail record page for To Do object.
    navDetailPageToDo(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'To_Do__c',
                actionName: 'view'
            }
        });
    }

    // Navigate to detail record page for Contact object.
    navDetailPageContact(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
    }

    // Navigate to standard edit record modal for To Do object.
    navEditPage(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'To_Do__c',
                actionName: 'edit'
            }
        });
    }

    // Delete record and send toast message on result.
    deleteToDo(event) {
        const recordId = event.target.dataset.id;
        deleteRecord(recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'To Do record deleted',
                        variant: 'success'
                    })
                );
                return refreshApex(this.wiredToDosResult);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
    }

}