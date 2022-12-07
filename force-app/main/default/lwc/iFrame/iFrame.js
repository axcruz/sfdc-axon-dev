import { api, LightningElement } from 'lwc';

export default class IFrame extends LightningElement {
  @api height = '500px';
  @api referrerPolicy = 'no-referrer';
  @api sandbox = '';
  @api url = '';
  @api width = '100%';
}