/**
 * plugins/vuetify.ts
 *
 * Framework documentation: https://vuetifyjs.com`
 */

// Styles
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'

// Composables
import { createVuetify } from 'vuetify'

export default createVuetify({
  theme: {
    themes: {
      dark: {
        colors: {
          primary: '#2ad424',
          secondary: '#5CBBF6',
          surface: '#141618',
          error: '#c0392b'
        },
      },
    },
  },
})
