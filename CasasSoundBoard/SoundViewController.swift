//
//  SoundViewController.swift
//  CasasSoundBoard
//
//  Created by Jorge Herrera Jara on 28/10/22.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("**************************")
            print(audioURL!)
            print("**************************")
            
            var setting:[String:AnyObject] = [:]
            setting[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            setting[AVSampleRateKey] = 44100.0 as AnyObject?
            setting[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: setting)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch {}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
}
