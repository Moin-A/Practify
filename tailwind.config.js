// tailwind.config.js
// Add these custom animations to your existing Tailwind configuration

module.exports = {
    content: [
      './app/views/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/components/**/*.{rb,html.erb}',
      './app/javascript/**/*.js',
      './app/assets/**/*.css',
    ],
    theme: {
      extend: {
        fontFamily: {
          'playfair': ['Playfair Display', 'serif'],
          'crimson': ['Crimson Pro', 'serif'],
          'dm-sans': ['DM Sans', 'sans-serif'],
        },
        colors: {
          clay: '#D4A574',
          terracotta: '#C17355',
          sage: '#8B9D83',
          cream: '#F7F3EE',
          charcoal: '#2C2C2C',
          'soft-white': '#FDFCFA',
          stone: '#B5A89A',
        },
        keyframes: {
          fadeSlideDown: {
            'from': { 
              opacity: '0', 
              transform: 'translateY(-20px)' 
            },
            'to': { 
              opacity: '1', 
              transform: 'translateY(0)' 
            }
          },
          fadeSlideUp: {
            'from': { 
              opacity: '0', 
              transform: 'translateY(30px)' 
            },
            'to': { 
              opacity: '1', 
              transform: 'translateY(0)' 
            }
          },
          shimmer: {
            '0%': { 
              transform: 'translateX(-100%)' 
            },
            '100%': { 
              transform: 'translateX(100%)' 
            }
          },
          grain: {
            '0%, 100%': { transform: 'translate(0, 0)' },
            '10%': { transform: 'translate(-5%, -10%)' },
            '20%': { transform: 'translate(-15%, 5%)' },
            '30%': { transform: 'translate(7%, -25%)' },
            '40%': { transform: 'translate(-5%, 25%)' },
            '50%': { transform: 'translate(-15%, 10%)' },
            '60%': { transform: 'translate(15%, 0%)' },
            '70%': { transform: 'translate(0%, 15%)' },
            '80%': { transform: 'translate(3%, 35%)' },
            '90%': { transform: 'translate(-10%, 10%)' }
          }
        },
        animation: {
          'fade-slide-down': 'fadeSlideDown 0.8s ease-out',
          'fade-slide-up': 'fadeSlideUp 0.8s ease-out backwards',
          'shimmer': 'shimmer 2s infinite',
          'grain': 'grain 8s steps(10) infinite',
        },
        boxShadow: {
          'soft': '0 8px 32px rgba(0, 0, 0, 0.06)',
          'medium': '0 12px 48px rgba(0, 0, 0, 0.08)',
          'deep': '0 20px 60px rgba(0, 0, 0, 0.12)',
        }
      }
    },
    plugins: [],
  }