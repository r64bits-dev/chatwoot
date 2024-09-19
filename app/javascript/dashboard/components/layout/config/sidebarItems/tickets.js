import { frontendURL } from '../../../../helper/URLHelper';
import { AllRoles } from '../../../../featureFlags';

const tickets = accountId => ({
  parentNav: 'tickets',
  routes: ['tickets_dashboard'],
  menuItems: [
    {
      icon: 'arrow-swap',
      label: 'TICKETS',
      key: 'allTickets',
      hasSubMenu: false,
      toState: frontendURL(`accounts/${accountId}/tickets`),
      toStateName: 'tickets_dashboard',
      roles: [AllRoles],
    },
  ],
});

export default tickets;
