//
//  CityListUITests.swift
//  UalaChallengeiOS
//
//  Created by Mariano Uriel Delgado on 12/05/2025.
//


// CityListUITests.swift
import XCTest

final class CityListUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    func testAppLaunch_LoadsCities_ShowsList() throws {
        let navBarTitle = app.navigationBars["Ciudades"]
        XCTAssertTrue(navBarTitle.waitForExistence(timeout: 10), "La barra de navegación 'Ciudades' debería existir.")

        let searchField = app.textFields["Buscar ciudad por nombre..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 20), "El campo de búsqueda debería aparecer.") // Aumentar timeout
        
        let firstCityPredicate = NSPredicate(format: "label BEGINSWITH[c] 'A'")
        let firstCityCell = app.cells.containing(firstCityPredicate).firstMatch
        XCTAssertTrue(firstCityCell.waitForExistence(timeout: 60), "Al menos una ciudad que empiece con 'A' debería aparecer en la lista después de cargar (timeout muy extendido).")
    }

    func testSearchField_FiltersList_FindsCordoba() throws {
        let searchField = app.textFields["Buscar ciudad por nombre..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 20), "El campo de búsqueda debe existir.")

        let initialCityPredicate = NSPredicate(format: "label BEGINSWITH[c] 'A'")
        let initialCityCell = app.cells.containing(initialCityPredicate).firstMatch
        XCTAssertTrue(initialCityCell.waitForExistence(timeout: 60), "La lista inicial debe cargar (timeout muy extendido).")
        
        let searchText = "Cordoba"
        searchField.tap()
        searchField.typeText(searchText)
        sleep(2)
        let targetCellLabel = "Cordoba, AR"
        let cordobaStaticTextInCell = app.staticTexts[targetCellLabel]
        let cordobaCellExists = cordobaStaticTextInCell.waitForExistence(timeout: 20) // Aumentar timeout
        if !cordobaCellExists {
            print("--------------------------------------------------------------------")
            print("FALLO AL ENCONTRAR EL TEXTO '\(targetCellLabel)' EN ALGUNA CELDA.")
            print("DEBUG DESCRIPTION DE LA APP:")
            print(app.debugDescription)
            print("--------------------------------------------------------------------")
        }
        XCTAssertTrue(cordobaCellExists, "El texto '\(targetCellLabel)' debería aparecer después de filtrar con '\(searchText)'. Revisa el debugDescription.")

        let alabamaStaticText = app.staticTexts["Alabama, US"]
        XCTAssertFalse(alabamaStaticText.waitForExistence(timeout: 2), "El texto de Alabama no debería existir después de filtrar por '\(searchText)'.")
    }

    func testTapCityRow_ShowsCityDetailViewWithMap() throws {
        let targetCityNameForSearch = "Cordoba"
        let targetCityDisplayNameForCell = "Cordoba, AR"
        let targetCityNameForTitle = "Cordoba"
        let searchField = app.textFields["Buscar ciudad por nombre..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 20))
        
        searchField.tap()
        searchField.typeText(targetCityNameForSearch)
        sleep(2)
        let cityCellToTap = app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", targetCityDisplayNameForCell)).firstMatch
        XCTAssertTrue(cityCellToTap.waitForExistence(timeout: 15), "La celda de '\(targetCityDisplayNameForCell)' debe existir para poder seleccionarla.")
        cityCellToTap.tap()
        sleep(1)

        let detailNavigationBar = app.navigationBars[targetCityNameForTitle]
        XCTAssertTrue(detailNavigationBar.waitForExistence(timeout: 10), "La barra de navegación de la vista de detalle con el título '\(targetCityNameForTitle)' debería aparecer.")
        let paisLabel = app.staticTexts["País"]
        let paisLabelExists = paisLabel.waitForExistence(timeout: 10)
        if !paisLabelExists {
            print("--------------------------------------------------------------------")
            print("FALLO AL ENCONTRAR LA ETIQUETA 'País' EN CityDetailView.")
            print("DEBUG DESCRIPTION DE LA APP (Detail View):")
            print(app.debugDescription)
            print("--------------------------------------------------------------------")
        }
        XCTAssertTrue(paisLabelExists, "La etiqueta 'País' (el Text, no el valor) debería estar visible en la vista de detalle.")
    }

    func testTapInfoButton_ShowsCityInfoSheet() throws {
        let targetCityNameForSearch = "Cordoba"
        let targetCityDisplayNameForCellAndSheetTitle = "Cordoba, AR"
        let cordobaCityIDForTest = 3860259
        let searchField = app.textFields["Buscar ciudad por nombre..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 20))
        searchField.tap()
        searchField.typeText(targetCityNameForSearch)
        sleep(2)

        let cityCell = app.cells.containing(NSPredicate(format: "label CONTAINS[c] %@", targetCityDisplayNameForCellAndSheetTitle)).firstMatch
        XCTAssertTrue(cityCell.waitForExistence(timeout: 15), "La celda de '\(targetCityDisplayNameForCellAndSheetTitle)' debe existir.")
        let infoButtonIdentifier = "infoButton_\(cordobaCityIDForTest)"
        let infoButton = cityCell.buttons[infoButtonIdentifier]
        let infoButtonExists = infoButton.waitForExistence(timeout: 10)
        if !infoButtonExists {
            print("--------------------------------------------------------------------")
            print("FALLO AL ENCONTRAR EL BOTÓN DE INFO CON ID '\(infoButtonIdentifier)'.")
            print("Asegúrate de que el botón en CityRowView tenga .accessibilityIdentifier(\"infoButton_\\(city.id)\")")
            print("Y que cordobaCityIDForTest (\(cordobaCityIDForTest)) sea el ID correcto para '\(targetCityDisplayNameForCellAndSheetTitle)'.")
            print("DEBUG DESCRIPTION DE LA CELDA (o app si es necesario):")
            print(app.debugDescription)
            print("--------------------------------------------------------------------")
        }
        XCTAssertTrue(infoButtonExists, "El botón de información con ID '\(infoButtonIdentifier)' debe existir en la celda.")
        infoButton.tap()
        sleep(1)
    }
}

