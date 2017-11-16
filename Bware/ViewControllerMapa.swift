 //
 //  ViewControllerMapa.swift
 //  Bware
 //
 //  Created by Alan Salazar on 21/10/17.
 //  Copyright © 2017 Alan Salazar. All rights reserved.
 //
 
 import UIKit
 import CoreLocation
 import MapKit
 import ContactsUI
 import MessageUI // para mensajes preprogramados
 
 class ViewControllerMapa: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, URLSessionDownloadDelegate, CNContactPickerDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate{
    
    //Para los mensajes, delegado
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // variables
    var menuIsShown: Bool = false
    var menuPinIsShown: Bool = false
    let gps =     CLLocationManager()
    var latitud: Double = 19.550376
    var longitud: Double = -99.212429
    var tareaTexto: URLSessionDownloadTask? = nil
    var arregloPines = [String.SubSequence]()
    var arregloContactos = [CNContact]()    // En este arreglo se guardan los contactos, para ponerlos en el table view.
    
    
    
    
    // OUTLETS
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var subtitulo: UITextField!
    @IBOutlet weak var ponerPin: UIView!
    @IBOutlet weak var tablaContactos: UITableView!
    
    
    var msg: String = "Esta es mi ubicación, estoy en peligro!"
    
    // ------------------------------ Metodo sms compartir ------------------------------
    @IBAction func compartir(_ sender: Any) {
        print("compartir")
        let mensaje    =    msg + "\nUbicación:\n" + String(format:"%f",(gps.location?.coordinate.latitude)!) + "\n" + String(format:"%f",(gps.location?.coordinate.longitude)!)
        let items:    [Any]    =    [mensaje]
        let ac =    UIActivityViewController(activityItems:    items,    applicationActivities:    nil)
        ac.excludedActivityTypes =    [UIActivityType.message,    .airDrop,    .print]
        self.present(ac,    animated:    true,    completion:    nil)
        
        //Enviar SMS
        print("enviando sms")
        if(MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = mensaje
            //iterate into arreglosContactos
            for contacto in arregloContactos {
                let firstNumber = contacto.phoneNumbers
                for num in firstNumber {
                    controller.recipients = [num.value.stringValue]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
            }
            //controller.recipients = ["5548384874"]//[phoneNumber.text]
            //controller.messageComposeDelegate = self
            //self.present(controller, animated: true, completion: nil)
        }
    }
    // ----------------------------------------------------------------------------
    
    
    //  Metodos para obtener contactos __________________________________________________________
    
    
    //Llama a la funcion de los contactos desde un boton
    @IBAction func agregarContacto(_ sender: Any) {
        showContactsPicker()
    }
    
    
    //Funcion para acceder a los contactos
    @IBAction func showContactsPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self;
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true) {
            
            
        }
    }
    
    
    
    
    // Esta funcion selecciona un contacto para agregarlo a la lista de contactos de emergencia.
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print(contact.givenName)
        
        
        self.perform(#selector(agregarContacto2(_:)), with: contact, afterDelay: 2)
        
        
        for contacto in arregloContactos{
            print(contacto.givenName)
            print(contacto.phoneNumbers)
        }
    }
    
    
    @objc func agregarContacto2(_ contact: CNContact) {
        //arregloContactos.append(contact)
        var flag: Bool = true
 
        for contacto in arregloContactos{
            if(contacto.familyName == contact.familyName && flag == true){
                if(contacto.givenName != contact.givenName){
                    flag = true
                }
                else{
                    flag = false
                }
            }else if(contacto.familyName != contact.familyName && flag == true){
                flag = true
            }else{
                flag = false
            }
        }
        
        if flag{
            arregloContactos.append(contact)
        }
        
        tablaContactos.reloadData()
    }
    
    
    
    
    // Metodos para poblar las tablas __________________________________________________________
    
    
    // Para el numero de hileras en el table view
    func numberOfSectionsInTableView(tableView:UITableView)->Int{
        return 1
    }
    
    
    
    
    // Para el tamaño del table view (Este tamaño deberá variar en cuestión del numero de contactos seleccionados)
    func tableView(_ tableView:UITableView,numberOfRowsInSection section:Int)->Int{
        return arregloContactos.count
    }
    
    
    // Para cambiar el contenido de la tabla
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath)->UITableViewCell{
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaContactos",for: indexPath)
        if(arregloContactos.count != 0){
            celda.textLabel?.text = arregloContactos[indexPath.row].givenName   // Agrega en la primera celda el nombre del contacto
            celda.detailTextLabel?.text = ((arregloContactos[indexPath.row].phoneNumbers[0].value ).value(forKey: "digits") as! String)
            // (contact.phoneNumbers[0].value as! CNPhoneNumber).valueForKey("digits") as! String
        }
        
        return celda
    }
    
    // NUEVOOOOOOOOOOOOOOOOOOOOOOOOOO09O0OO0O0O0O0O0O0O0O0O0OO0O
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaContactos",for: indexPath)
        
        let url: NSURL = URL(string: ((arregloContactos[indexPath.row].phoneNumbers[0].value ).value(forKey: "digits") as! String))! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        print("\n")
        print(arregloContactos[indexPath.row].phoneNumbers)
    }
    
    func makeAPhoneCall()  {
        let url: NSURL = URL(string: "TEL://1234567890")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    // NUEVOOOOOOOOOOOOOOOOOOOOOOOOOO09O0OO0O0O0O0O0O0O0O0O0OO0O
    
    // Métodos para sobreescribir los user defaults  ____________________________________________
    
    
    @objc func iniciar(){
        
        let preferencias = UserDefaults.standard
        
        preferencias.synchronize()
        /**
         if let arregloContactosGuardados = preferencias.array(forKey: "listaContactos"){
         arregloContactos = arregloContactosGuardados as! [CNContact]
         tablaContactos.reloadData()
         }
         **/
        
        
        let decoded = UserDefaults.standard.object(forKey: "listaContactos") as? Data
        let arregloContactosGuardados = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [CNContact]
        
        arregloContactos = arregloContactosGuardados

        if arregloContactos.count > 0 {
            print("\n(arregloContactos.count)\n\(arregloContactos[0].givenName)")
        }
        
        tablaContactos.reloadData()
    }
    
    
    @objc func terminar(){
       let preferencias = UserDefaults.standard
    
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: arregloContactos)
        preferencias.set(encodeData, forKey: "listaContactos")

        preferencias.synchronize()
    }
    
    
     // Métodos para sobreescribir los user defaults  ____________________________________________
    
    
    
    
    
    
    
    //___________________________________________________________________________________________

    override func viewDidLoad() {
        super.viewDidLoad()
        descargarPines()
        configurarMapa()
        // Do any additional setup after loading the view.
        // listMajors()
        //showContactsPicker()
        
        /**
        // Notificaciones
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(iniciar), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        nc.addObserver(self, selector: #selector(terminar), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        */
        
    }
    
    // ---------------------------------------------- PREFERENCIAS ----------------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        print("Entrando")
        let preferencias = UserDefaults.standard
        preferencias.synchronize()
        
        let decoded = UserDefaults.standard.object(forKey: "listaContactos") as! Data
        let arregloContactosGuardados = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [CNContact]
        arregloContactos = arregloContactosGuardados
        
        if arregloContactos.count > 0 {
            print("\n(arregloContactos.count)\n\(arregloContactos[0].givenName)")
        }
        
        tablaContactos.reloadData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        print("Saliendo")
        let preferencias = UserDefaults.standard
        
        let encodeData = NSKeyedArchiver.archivedData(withRootObject: arregloContactos)
        preferencias.set(encodeData, forKey: "listaContactos")

        preferencias.synchronize()
    }
     // ---------------------------------------------------------------------------------------------------------
    
    
    
    @IBAction func subirAlerta(_ sender: Any) {
        uploadPin(title: "Alerta", subtitle: subtitulo.text!, lat: (gps.location?.coordinate.latitude)!, lon: (gps.location?.coordinate.longitude)!)
        //uploadPin(title: "Aledsdrta", subtitle: "sda", lat:123.34, lon:12.3432)
        btPin(titulo: "Alerta", subtitulo: subtitulo.text!, lat: (gps.location?.coordinate.latitude)!, long: (gps.location?.coordinate.longitude)!)
        menuPinIsShown = false;
        ponerPin.isHidden = true;
    }

    
    @IBAction func mostrarPonerPines(_ sender: Any) {
        if menuPinIsShown{
            ponerPin.isHidden = true
            menuPinIsShown = false
        } else {
            ponerPin.isHidden = false
            menuPinIsShown = true
        }
    }
    
    
    @IBAction func mostrarMenu(_ sender: Any) {
        if menuIsShown{
            menuView.isHidden = true
            menuIsShown = false
        } else {
            menuView.isHidden = false
            menuIsShown = true
        }
    }
    
    
    func descargarPines(){
        let dir = "http://bware32.000webhostapp.com/pin.dat"
        if let url = URL(string: dir) {
            let config = URLSessionConfiguration.default
            let sesion = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            tareaTexto = sesion.downloadTask(with: url)
            tareaTexto?.resume() // Inicia la descarga
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        subtitulo.resignFirstResponder()
    }
    
    
    func uploadPin(title: String,subtitle: String, lat: Double, lon: Double){
        //code source: https://stackoverflow.com/questions/37400639/post-data-to-a-php-method-from-swift
        //code source: https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
        let url = URL(string: "http://bware32.000webhostapp.com/postPin.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        //let postString = "id=13&name=Jack"
        let postString = "title=\(title)&subtitle=\(subtitle)&lat=\(lat)&lon=\(lon)";
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {  // check for fundamental networking error
                //print("error=\(error)")
                print("Error 1")
                return
            }
            
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
                print("Error")
            }
            
            
            //let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    func btPin( titulo:String, subtitulo: String, lat: Double, long: Double) {
        let coordenadaPin = CLLocationCoordinate2DMake(lat,long)
        let pin = MKPointAnnotation()
        pin.coordinate = coordenadaPin
        pin.title = titulo
        pin.subtitle = subtitulo
        mapa.addAnnotation(pin)
    }
    
    
    private
    func configurarMapa() {
        mapa.delegate = self
        gps.delegate = self
        gps.desiredAccuracy = kCLLocationAccuracyBest
        gps.requestWhenInUseAuthorization()
        // Tamaño inicial del mapa
        //let centro = CLLocationCoordinate2DMake(self.latitud,self.longitud)
        let centro = CLLocationCoordinate2DMake((gps.location?.coordinate.latitude)!,(gps.location?.coordinate.longitude)!)
        
        let span = MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01)
        let region = MKCoordinateRegionMake(centro, span)
        mapa.region = region
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            gps.startUpdatingLocation()
        }else if status == .denied{
            gps.stopUpdatingLocation()
            print("Puedes activar la localizacion en Ajustes")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let posicion = locations.last!
        self.latitud = posicion.coordinate.latitude
        self.longitud = posicion.coordinate.longitude
    }
    
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    // Metodos del delegado
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Error al descargar")
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let avance = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
        print("Avance: \(avance*100)%")
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do{
            
            
            
            
            let datosBin = try Data.init(contentsOf: location, options: .alwaysMapped)
            let respuesta = downloadTask.response as! HTTPURLResponse
            if respuesta.statusCode == 200 {
                
                
                // Parsear los datos JSON
                let cadena = String(data: datosBin, encoding: .utf8)
                let resultadoCadena  = cadena
                print(resultadoCadena!)
                
                
                
                
                
                
                let listaPines = resultadoCadena?.split(separator: "\n")
                // var arregloPines = [String.SubSequence]()
                for pin in listaPines!{
                    //let pines: String = pin.split(separator: ",")
                    arregloPines.append(pin)
                }
                
                
                // Iteracion arreglo
                var titulo: String
                var subtitulo: String
                var latitud: Double
                var longitud: Double
                for llamadas in arregloPines{
                    var llamada = llamadas.split(separator: ",")
                    titulo = String(llamada[0])
                    subtitulo = String(llamada[1])
                    latitud = Double(llamada[2])!
                    longitud = Double(llamada[3])!
                    btPin(titulo: titulo, subtitulo: subtitulo, lat: latitud, long: longitud)
                }
                
                
            } else {
                print("Error: \(respuesta.statusCode)")
            }
        } catch {
            
            
        }
    }
    
    
    
    
    
    
    
 }
 

