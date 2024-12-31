import {
  OPERATOR_TYPES_1,
  OPERATOR_TYPES_2,
  OPERATOR_TYPES_3,
  OPERATOR_TYPES_6,
} from './operators';

export const AUTOMATIONS = {
  message_created: {
    conditions: [
      {
        key: 'message_type',
        name: 'Tipo de Mensagem', // traduzido
        attributeI18nKey: 'MESSAGE_TYPE',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'content',
        name: 'Conteúdo da Mensagem', // traduzido
        attributeI18nKey: 'MESSAGE_CONTAINS',
        inputType: 'comma_separated_plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'email',
        name: 'Email', // traduzido
        attributeI18nKey: 'EMAIL',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'inbox_id',
        name: 'Caixa de Entrada', // traduzido
        attributeI18nKey: 'INBOX',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'conversation_language',
        name: 'Idioma da Conversa', // traduzido
        attributeI18nKey: 'CONVERSATION_LANGUAGE',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'phone_number',
        name: 'Número de Telefone', // traduzido
        attributeI18nKey: 'PHONE_NUMBER',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_6,
      },
    ],
    actions: [
      {
        key: 'assign_agent',
        name: 'Atribuir a agente', // traduzido
        attributeI18nKey: 'ASSIGN_AGENT',
      },
      {
        key: 'assign_team',
        name: 'Atribuir a equipe', // traduzido
        attributeI18nKey: 'ASSIGN_TEAM',
      },
      {
        key: 'add_label',
        name: 'Adicionar uma etiqueta', // traduzido
        attributeI18nKey: 'ADD_LABEL',
      },
      {
        key: 'remove_label',
        name: 'Remover uma etiqueta', // traduzido
        attributeI18nKey: 'REMOVE_LABEL',
      },
      {
        key: 'send_email_to_team',
        name: 'Enviar um e-mail para a equipe', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TO_TEAM',
      },
      {
        key: 'send_message',
        name: 'Enviar uma mensagem', // traduzido
        attributeI18nKey: 'SEND_MESSAGE',
      },
      {
        key: 'send_email_transcript',
        name: 'Enviar uma transcrição de e-mail', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TRANSCRIPT',
      },
      {
        key: 'mute_conversation',
        name: 'Silenciar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'snooze_conversation',
        name: 'Adiar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'resolve_conversation',
        name: 'Resolver conversa', // traduzido
        attributeI18nKey: 'RESOLVE_CONVERSATION',
      },
      {
        key: 'send_webhook_event',
        name: 'Enviar evento de webhook', // traduzido
        attributeI18nKey: 'SEND_WEBHOOK_EVENT',
      },
      {
        key: 'send_attachment',
        name: 'Enviar anexo', // traduzido
        attributeI18nKey: 'SEND_ATTACHMENT',
      },
    ],
  },
  conversation_created: {
    conditions: [
      {
        key: 'status',
        name: 'Status', // traduzido
        attributeI18nKey: 'STATUS',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'browser_language',
        name: 'Idioma do Navegador', // traduzido
        attributeI18nKey: 'BROWSER_LANGUAGE',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'mail_subject',
        name: 'Assunto do E-mail', // traduzido
        attributeI18nKey: 'MAIL_SUBJECT',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'country_code',
        name: 'País', // traduzido
        attributeI18nKey: 'COUNTRY_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'phone_number',
        name: 'Número de Telefone', // traduzido
        attributeI18nKey: 'PHONE_NUMBER',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_6,
      },
      {
        key: 'referer',
        name: 'Link de Referência', // traduzido
        attributeI18nKey: 'REFERER_LINK',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'email',
        name: 'Email', // traduzido
        attributeI18nKey: 'EMAIL',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'inbox_id',
        name: 'Caixa de Entrada', // traduzido
        attributeI18nKey: 'INBOX',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'conversation_language',
        name: 'Idioma da Conversa', // traduzido
        attributeI18nKey: 'CONVERSATION_LANGUAGE',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'priority',
        name: 'Prioridade', // traduzido
        attributeI18nKey: 'PRIORITY',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
    ],
    actions: [
      {
        key: 'assign_agent',
        name: 'Atribuir a agente', // traduzido
        attributeI18nKey: 'ASSIGN_AGENT',
      },
      {
        key: 'assign_team',
        name: 'Atribuir a equipe', // traduzido
        attributeI18nKey: 'ASSIGN_TEAM',
      },
      {
        key: 'send_email_to_team',
        name: 'Enviar um e-mail para a equipe', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TO_TEAM',
      },
      {
        key: 'send_message',
        name: 'Enviar uma mensagem', // traduzido
        attributeI18nKey: 'SEND_MESSAGE',
      },
      {
        key: 'send_email_transcript',
        name: 'Enviar uma transcrição de e-mail', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TRANSCRIPT',
      },
      {
        key: 'mute_conversation',
        name: 'Silenciar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'snooze_conversation',
        name: 'Adiar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'resolve_conversation',
        name: 'Resolver conversa', // traduzido
        attributeI18nKey: 'RESOLVE_CONVERSATION',
      },
      {
        key: 'send_webhook_event',
        name: 'Enviar evento de webhook', // traduzido
        attributeI18nKey: 'SEND_WEBHOOK_EVENT',
      },
      {
        key: 'send_attachment',
        name: 'Enviar anexo', // traduzido
        attributeI18nKey: 'SEND_ATTACHMENT',
      },
    ],
  },
  conversation_updated: {
    conditions: [
      {
        key: 'status',
        name: 'Status', // traduzido
        attributeI18nKey: 'STATUS',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'browser_language',
        name: 'Idioma do Navegador', // traduzido
        attributeI18nKey: 'BROWSER_LANGUAGE',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'mail_subject',
        name: 'Assunto do E-mail', // traduzido
        attributeI18nKey: 'MAIL_SUBJECT',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'country_code',
        name: 'País', // traduzido
        attributeI18nKey: 'COUNTRY_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'referer',
        name: 'Link de Referência', // traduzido
        attributeI18nKey: 'REFERER_LINK',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'phone_number',
        name: 'Número de Telefone', // traduzido
        attributeI18nKey: 'PHONE_NUMBER',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_6,
      },
      {
        key: 'assignee_id',
        name: 'Atribuído', // traduzido
        attributeI18nKey: 'ASSIGNEE_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_3,
      },
      {
        key: 'team_id',
        name: 'Equipe', // traduzido
        attributeI18nKey: 'TEAM_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_3,
      },
      {
        key: 'email',
        name: 'Email', // traduzido
        attributeI18nKey: 'EMAIL',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'inbox_id',
        name: 'Caixa de Entrada', // traduzido
        attributeI18nKey: 'INBOX',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'conversation_language',
        name: 'Idioma da Conversa', // traduzido
        attributeI18nKey: 'CONVERSATION_LANGUAGE',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'priority',
        name: 'Prioridade', // traduzido
        attributeI18nKey: 'PRIORITY',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
    ],
    actions: [
      {
        key: 'assign_agent',
        name: 'Atribuir a agente', // traduzido
        attributeI18nKey: 'ASSIGN_AGENT',
      },
      {
        key: 'assign_team',
        name: 'Atribuir a equipe', // traduzido
        attributeI18nKey: 'ASSIGN_TEAM',
      },
      {
        key: 'send_email_to_team',
        name: 'Enviar um e-mail para a equipe', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TO_TEAM',
      },
      {
        key: 'send_message',
        name: 'Enviar uma mensagem', // traduzido
        attributeI18nKey: 'SEND_MESSAGE',
      },
      {
        key: 'send_email_transcript',
        name: 'Enviar uma transcrição de e-mail', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TRANSCRIPT',
      },
      {
        key: 'mute_conversation',
        name: 'Silenciar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'snooze_conversation',
        name: 'Adiar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'resolve_conversation',
        name: 'Resolver conversa', // traduzido
        attributeI18nKey: 'RESOLVE_CONVERSATION',
      },
      {
        key: 'send_webhook_event',
        name: 'Enviar evento de webhook', // traduzido
        attributeI18nKey: 'SEND_WEBHOOK_EVENT',
      },
      {
        key: 'send_attachment',
        name: 'Enviar anexo', // traduzido
        attributeI18nKey: 'SEND_ATTACHMENT',
      },
    ],
  },
  conversation_opened: {
    conditions: [
      {
        key: 'browser_language',
        name: 'Idioma do Navegador', // traduzido
        attributeI18nKey: 'BROWSER_LANGUAGE',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'email',
        name: 'Email', // traduzido
        attributeI18nKey: 'EMAIL',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'mail_subject',
        name: 'Assunto do E-mail', // traduzido
        attributeI18nKey: 'MAIL_SUBJECT',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'country_code',
        name: 'País', // traduzido
        attributeI18nKey: 'COUNTRY_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'referer',
        name: 'Link de Referência', // traduzido
        attributeI18nKey: 'REFERER_LINK',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_2,
      },
      {
        key: 'assignee_id',
        name: 'Atribuído', // traduzido
        attributeI18nKey: 'ASSIGNEE_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_3,
      },
      {
        key: 'phone_number',
        name: 'Número de Telefone', // traduzido
        attributeI18nKey: 'PHONE_NUMBER',
        inputType: 'plain_text',
        filterOperators: OPERATOR_TYPES_6,
      },
      {
        key: 'team_id',
        name: 'Equipe', // traduzido
        attributeI18nKey: 'TEAM_NAME',
        inputType: 'search_select',
        filterOperators: OPERATOR_TYPES_3,
      },
      {
        key: 'inbox_id',
        name: 'Caixa de Entrada', // traduzido
        attributeI18nKey: 'INBOX',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'conversation_language',
        name: 'Idioma da Conversa', // traduzido
        attributeI18nKey: 'CONVERSATION_LANGUAGE',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
      {
        key: 'priority',
        name: 'Prioridade', // traduzido
        attributeI18nKey: 'PRIORITY',
        inputType: 'multi_select',
        filterOperators: OPERATOR_TYPES_1,
      },
    ],
    actions: [
      {
        key: 'assign_agent',
        name: 'Atribuir a agente', // traduzido
        attributeI18nKey: 'ASSIGN_AGENT',
      },
      {
        key: 'assign_team',
        name: 'Atribuir a equipe', // traduzido
        attributeI18nKey: 'ASSIGN_TEAM',
      },
      {
        key: 'send_email_to_team',
        name: 'Enviar um e-mail para a equipe', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TO_TEAM',
      },
      {
        key: 'send_message',
        name: 'Enviar uma mensagem', // traduzido
        attributeI18nKey: 'SEND_MESSAGE',
      },
      {
        key: 'send_email_transcript',
        name: 'Enviar uma transcrição de e-mail', // traduzido
        attributeI18nKey: 'SEND_EMAIL_TRANSCRIPT',
      },
      {
        key: 'mute_conversation',
        name: 'Silenciar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'snooze_conversation',
        name: 'Adiar conversa', // traduzido
        attributeI18nKey: 'MUTE_CONVERSATION',
      },
      {
        key: 'send_webhook_event',
        name: 'Enviar evento de webhook', // traduzido
        attributeI18nKey: 'SEND_WEBHOOK_EVENT',
      },
      {
        key: 'send_attachment',
        name: 'Enviar anexo', // traduzido
        attributeI18nKey: 'SEND_ATTACHMENT',
      },
    ],
  },
};

export const AUTOMATION_RULE_EVENTS = [
  {
    key: 'conversation_created',
    value: 'Conversa criada', // traduzido
  },
  {
    key: 'conversation_updated',
    value: 'Conversa atualizada', // traduzido
  },
  {
    key: 'message_created',
    value: 'Mensagem criada', // traduzido
  },
  {
    key: 'conversation_opened',
    value: 'Conversa aberta', // traduzido
  },
];

export const AUTOMATION_ACTION_TYPES = [
  {
    key: 'assign_agent',
    label: 'Atribuir a agente', // traduzido
    inputType: 'search_select',
  },
  {
    key: 'assign_team',
    label: 'Atribuir a equipe', // traduzido
    inputType: 'search_select',
  },
  {
    key: 'add_label',
    label: 'Adicionar uma etiqueta', // traduzido
    inputType: 'multi_select',
  },
  {
    key: 'remove_label',
    label: 'Remover uma etiqueta', // traduzido
    inputType: 'multi_select',
  },
  {
    key: 'send_email_to_team',
    label: 'Enviar um e-mail para a equipe', // traduzido
    inputType: 'team_message',
  },
  {
    key: 'send_email_transcript',
    label: 'Enviar uma transcrição de e-mail', // traduzido
    inputType: 'email',
  },
  {
    key: 'mute_conversation',
    label: 'Silenciar conversa', // traduzido
    inputType: null,
  },
  {
    key: 'snooze_conversation',
    label: 'Adiar conversa', // traduzido
    inputType: null,
  },
  {
    key: 'resolve_conversation',
    label: 'Resolver conversa', // traduzido
    inputType: null,
  },
  {
    key: 'send_webhook_event',
    label: 'Enviar evento de webhook', // traduzido
    inputType: 'url',
  },
  {
    key: 'send_attachment',
    label: 'Enviar anexo', // traduzido
    inputType: 'attachment',
  },
  {
    key: 'send_message',
    label: 'Enviar uma mensagem', // traduzido
    inputType: 'textarea',
  },
  {
    key: 'change_priority',
    label: 'Alterar prioridade', // traduzido
    inputType: 'search_select',
  },
];
