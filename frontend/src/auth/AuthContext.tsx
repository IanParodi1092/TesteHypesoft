import { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react'
import Keycloak from 'keycloak-js'
import type { KeycloakInstance } from 'keycloak-js'

const keycloak = new Keycloak({
  url: import.meta.env.VITE_KEYCLOAK_URL,
  realm: import.meta.env.VITE_KEYCLOAK_REALM,
  clientId: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
})

type AuthContextValue = {
  keycloak: KeycloakInstance
  isAuthenticated: boolean
  isReady: boolean
  error?: string
  token?: string
  login: () => void
  logout: () => void
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [token, setToken] = useState<string | undefined>()
  const [isReady, setIsReady] = useState(false)
  const [error, setError] = useState<string | undefined>()
  const hasInitialized = useRef(false)

  useEffect(() => {
    if (hasInitialized.current) {
      return
    }

    hasInitialized.current = true

    if (!import.meta.env.VITE_KEYCLOAK_URL || !import.meta.env.VITE_KEYCLOAK_REALM || !import.meta.env.VITE_KEYCLOAK_CLIENT_ID) {
      setError('Configuração do Keycloak ausente. Verifique as variáveis VITE_KEYCLOAK_*')
      setIsReady(true)
      return
    }

    keycloak.onAuthSuccess = () => {
      setError(undefined)
    }
    keycloak.onAuthError = () => {
      setError('Falha de autenticação no Keycloak.')
    }
    keycloak.onAuthRefreshError = () => {
      setError('Não foi possível renovar a sessão no Keycloak.')
      setIsAuthenticated(false)
      setToken(undefined)
    }
    keycloak.onAuthLogout = () => {
      setIsAuthenticated(false)
      setToken(undefined)
    }

    keycloak
      .init({
        onLoad: 'check-sso',
        silentCheckSsoRedirectUri: `${window.location.origin}/silent-check-sso.html`,
        pkceMethod: 'S256',
        checkLoginIframe: false,
      })
      .then((authenticated) => {
        setIsAuthenticated(authenticated)
        setToken(keycloak.token)
        setIsReady(true)
      })
      .catch((initError) => {
        setIsAuthenticated(false)
        setIsReady(true)
        setError('Não foi possível conectar ao Keycloak. Verifique a configuração e o serviço.')
        console.error('Keycloak init error', initError)
      })
  }, [])

  useEffect(() => {
    const interval = setInterval(() => {
      keycloak
        .updateToken(60)
        .then((refreshed) => {
          if (refreshed) {
            setToken(keycloak.token)
          }
        })
        .catch(() => {
          setIsAuthenticated(false)
          setToken(undefined)
        })
    }, 30000)

    return () => clearInterval(interval)
  }, [])

  const login = useCallback(async () => {
    if (!isReady) {
      return
    }

    try {
      const loginUrl = await keycloak.createLoginUrl({ redirectUri: window.location.origin })
      window.location.assign(loginUrl)
    } catch (loginError) {
      setError('Falha ao iniciar o login no Keycloak.')
      console.error('Keycloak login error', loginError)
    }
  }, [isReady])

  const logout = useCallback(() => {
    keycloak.logout({ redirectUri: window.location.origin })
  }, [])

  const value = useMemo(
    () => ({
      keycloak,
      isAuthenticated,
      isReady,
      error,
      token,
      login,
      logout,
    }),
    [isAuthenticated, isReady, error, token, login, logout]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
