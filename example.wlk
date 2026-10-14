// 1) mision.esUtil(pirata)
// 2a) barco.puedeFormarParte(pirata)
// 2b) barco.reclutar(pirata)
// 2c) barco.cambiarMision(nuevaMision)
// 3) barco.esTemible()
// 5) barco.anclaEn(lugar)

const grogXD = "botellaDeGrogXD"

object busquedaDelTesoro {
  const itemsRequeridos = ["brujula", "mapa", grogXD] 

  method esUtil(pirata) = 
    pirata.tieneAlgunoDe(itemsRequeridos) and pirata.monedas() <= 5

  method puedeSerRealizadaPor(barco) =
    barco.alguienTiene("llaveDeCofre") 
}

class ConvertirseEnLeyenda {
  const itemObligatorio

  method esUtil(pirata) = 
    pirata.cantidadDeItems() >= 10 and pirata.tiene(itemObligatorio)

  method puedeSerRealizadaPor(barco) = true

}

class Saqueo {
  const victima
  const monedasRequeridas

  method esUtil(pirata) =
    pirata.monedas() < monedasRequeridas 
      and pirata.seAnimaASaquear(victima)

  method puedeSerRealizadaPor(barco) = victima.esVulnerable(barco)
} 

class BarcoPirata {
  const tripulacion = []
  const capacidadMaxima
  var mision

  method puedeFormarParte(pirata) =
    self.tieneLugarDeMas() and mision.esUtil(pirata)

  method esSaqueablePor(pirata) = pirata.estaPasadoDeGrogXD()
  
  method tieneLugarDeMas() = self.cantidadDeTripulantes() < capacidadMaxima

  method cantidadDeTripulantes() = tripulacion.size()

  method reclutar(pirata) {
    if (not self.puedeFormarParte(pirata)) {
      throw new DomainException(message = "No te podés subir, a tu casa")
      // self.error("No te podés subir, a tu casa")
    }

    tripulacion.add(pirata)
  }

  method cambiarMision(nuevaMision) {
    // tripulacion = tripulacion.filter(...)
    tripulacion.removeAllSuchThat({ pirata =>
      not nuevaMision.esUtil(pirata) })

    mision = nuevaMision
  }

  method esTemible() = 
    self.puedeRealizarLaMision() 
      and self.tripulantesUtilesParaMision().size() >= 5

  method tripulantesUtilesParaMision() = 
    tripulacion.filter({ pirata => mision.esUtil(pirata) })

  method puedeRealizarLaMision() =
    self.tieneSuficienteTripulacion() 
      and mision.puedeSerRealizadaPor(self) 

  method tieneSuficienteTripulacion() = 
    self.cantidadDeTripulantes() > capacidadMaxima * 0.9

  method alguienTiene(item) =
    tripulacion.any({ pirata => pirata.tiene(item) }) 

  method esVulnerable(otroBarco) =
    otroBarco.cantidadDeTripulantes() / 2 > self.cantidadDeTripulantes()

  method puedeCopar(lugar) =
    self.cantidadDeTripulantes() >= lugar.cantidadDeHabitantes() * 0.4

  method estanTodosPasadosDeGrogXD() =
    tripulacion.all({ pirata => pirata.estaPasadoDeGrogXD() })

  method anclaEn(lugar) {
    self.escabiarTripulacion(lugar)
    self.perderAlMasBorrachoEn(lugar)
  }

  method escabiarTripulacion(lugar) {
    tripulacion
      .filter({ pirata => pirata.puedePagar(lugar.precioGrogXD()) })
      .forEach({ pirata => pirata.escabia(lugar.precioGrogXD()) })
  }

  method perderAlMasBorrachoEn(lugar) {
    const pirataMasBorracho = tripulacion.max({ pirata => pirata.ebriedad() })
    tripulacion.remove(pirataMasBorracho)
    lugar.agregarNuevoHabitante()
  }
}

class CiudadCostera {
  var property cantidadDeHabitantes
  const property precioGrogXD

  method esSaqueablePor(pirata) = pirata.estaMasEbrioQue(50)

  method esVulnerable(barco) = barco.puedeCopar(self)

  method agregarNuevoHabitante() { 
    cantidadDeHabitantes += 1
  }
}

class Isla inherits CiudadCostera { 
  override method esVulnerable(barco) =
    super(barco) or barco.estanTodosPasadosDeGrogXD()
}

class Pirata {
  const items = []
  var property ebriedad
  var property monedas

  method tieneAlgunoDe(otrosItems) = 
    not items.intersection(otrosItems).isEmpty()
  
  method tiene(unItem) = items.contains(unItem)

  method cantidadDeItems() = items.size()

  method seAnimaASaquear(victima) = victima.esSaqueablePor(self)

  method estaPasadoDeGrogXD() = 
    self.estaMasEbrioQue(90) and self.tiene(grogXD)

  method estaMasEbrioQue(nivelDeEbriedad) = 
    ebriedad >= nivelDeEbriedad

  method puedePagar(precio) = monedas >= precio

  method escabia(precioTrago) {
    self.pagar(precioTrago)
    ebriedad += 5
  }

  method pagar(precio) {
    if (not self.puedePagar(precio)) {
      self.error("No tengo guita suficiente")
    }
    monedas -= precio
  }
}

class Espia inherits Pirata {
  override method estaPasadoDeGrogXD() = false

  override method seAnimaASaquear(victima) =
    super(victima) and self.tiene("permisoDeLaCorona")
}