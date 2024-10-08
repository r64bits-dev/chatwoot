import { AdminSupervisorRoles } from '../../../../featureFlags';
import { frontendURL } from '../../../../helper/URLHelper';

const SettingsContent = () => import('../Wrapper.vue');
const Index = () => import('./Index.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/labels'),
      component: SettingsContent,
      props: {
        headerTitle: 'LABEL_MGMT.HEADER',
        icon: 'tag',
        showNewButton: false,
      },
      children: [
        {
          path: '',
          name: 'labels_wrapper',
          roles: AdminSupervisorRoles,
          redirect: 'list',
        },
        {
          path: 'list',
          name: 'labels_list',
          roles: AdminSupervisorRoles,
          component: Index,
        },
      ],
    },
  ],
};
