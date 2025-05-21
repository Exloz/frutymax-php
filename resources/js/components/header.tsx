"use client"

import { useState } from "react"
import React from "react"
import { Search, User, Menu } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet"
import CartDrawer from "@/components/cart-drawer"
import SearchBar from "@/components/search-bar"
import MobileSearch from "@/components/mobile-search"

interface HeaderProps {
  onSearch?: (term: string) => void
}

export default function Header({ onSearch }: HeaderProps) {
  const [mobileSearchVisible, setMobileSearchVisible] = useState(false)

  const toggleMobileSearch = () => {
    setMobileSearchVisible(!mobileSearchVisible)
  }

  return (
    <header className="sticky top-0 z-50 w-full border-b bg-green-500 text-white">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-2 md:gap-6">
          <Sheet>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="md:hidden text-white hover:bg-green-600">
                <Menu className="h-6 w-6" />
                <span className="sr-only">Toggle menu</span>
              </Button>
            </SheetTrigger>
            <SheetContent side="left" className="w-[300px] sm:w-[400px]">
              <nav className="flex flex-col gap-4 mt-8">
                <a href="/" className="text-lg font-medium">
                  Inicio
                </a>
                <a href="/" className="text-lg font-medium">
                  Frutas
                </a>
                <a href="/" className="text-lg font-medium">
                  Verduras
                </a>
                <a href="/" className="text-lg font-medium">
                  Pulpas
                </a>
              </nav>
            </SheetContent>
          </Sheet>

          <a href="/" className="flex items-center gap-2">
            <span className="text-xl font-bold">FrutyMax</span>
          </a>

          <nav className="hidden md:flex items-center gap-6">
            <a href="/" className="text-sm font-medium hover:underline">
              Inicio
            </a>
            <a href="/" className="text-sm font-medium hover:underline">
              Frutas
            </a>
            <a href="/" className="text-sm font-medium hover:underline">
              Verduras
            </a>
            <a href="/" className="text-sm font-medium hover:underline">
              Pulpas
            </a>
          </nav>
        </div>

        <div className="hidden md:flex items-center relative w-full max-w-sm mx-4">
          <SearchBar onSearch={onSearch} placeholder="Buscar productos..." className="bg-white text-black" />
        </div>

        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            className="text-white hover:bg-green-600 md:hidden"
            onClick={toggleMobileSearch}
          >
            <Search className="h-5 w-5" />
            <span className="sr-only">Buscar</span>
          </Button>

          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" className="hidden md:flex bg-white text-green-600 hover:bg-gray-100">
              Iniciar sesión
            </Button>
            <Button variant="outline" size="sm" className="hidden md:flex bg-white text-green-600 hover:bg-gray-100">
              Registrarse
            </Button>
            <Button variant="ghost" size="icon" className="md:hidden text-white hover:bg-green-600">
              <User className="h-5 w-5" />
              <span className="sr-only">Cuenta</span>
            </Button>
          </div>

          <CartDrawer />
        </div>
      </div>

      {/* Búsqueda móvil */}
      {mobileSearchVisible && <MobileSearch onSearch={onSearch} onClose={() => setMobileSearchVisible(false)} />}
    </header>
  )
}
