import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importa el timer para simular la autenticación


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
//crear variable para mostrar u ocultar la contraseña
  bool _obscureText = true;
  //SMI: es una clase que se utiliza para controlar la animación de Rive desde el código de Flutter, es el cerebro de la animación de Rive, es decir, es el encargado de controlar las variables y los triggers de la animación de Rive desde el código de Flutter
  //crear el cerebro de la animación de Rive
  StateMachineController? _controller;
  //SMI: State Machine Input: es una variable que se utiliza para controlar la animación de Rive desde el código de Flutter
  SMIBool? _isChecking; //variable para controlar la animación de Rive cuando el usuario está escribiendo en el campo de email
  SMIBool? _isHandsUp; //variable para controlar la animación de Rive cuando el usuario está escribiendo en el campo de password
  SMITrigger? _trigSuccess; //variable para controlar la animación de Rive cuando el usuario hace clic en el botón de login
  SMITrigger? _trigFail; //variable para controlar la animación de Rive cuando el usuario hace clic en el botón de login y la autenticación falla
  SMINumber? _numLook; //variable para controlar la animación de Rive cuando el usuario mueve el mouse sobre el campo de email o password

  //paso 1.1: crear variables para el focus de los campos de texto
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  //3.2 timer para dejar de escribir
  Timer? _typingDebounce;
  
  //paso 1.2: Listenrs para FocusNodes (Oyentes/Chismosos)
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if(_emailFocusNode.hasFocus) {
        if(_isHandsUp != null){
          //No tapes los ojos al ver email
          _isHandsUp?.change(false);
          //mirada neutral
          _numLook?.value = 50.0;
        }
      }
    }); 
    _passwordFocusNode.addListener(() {
      _isHandsUp?.change(_passwordFocusNode.hasFocus); //Levantar las manos al ver password
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;//obtenemos el tamaño de la pantalla para ajustar la animación y los campos de texto
    return Scaffold(
      body: SafeArea(
        child: Padding( //agregamos un padding para que la animación y los campos de texto no estén pegados a los bordes de la pantalla
          padding: const EdgeInsets.symmetric(horizontal: 20.0),//padding horizontal de 20 para que la animación y los campos de texto no estén pegados a los bordes de la pantalla
          child: Column(
            children: [
              Expanded(
                child: RiveAnimation.asset('animated_login_bear.riv',//agregamos la animación de Rive en la parte superior de la pantalla
                stateMachines:['Login Machine'],//especificamos el nombre de la máquina de estados que queremos utilizar para controlar la animación de Rive
                onInit: (artboart){
                  _controller = StateMachineController.fromArtboard(artboart, 'Login Machine');
                  if(_controller == null) return;
                  artboart.addController(_controller!);
                  //vinculamos las variables de la animación de Rive con las variables de Flutter para poder controlar la animación desde el código de Flutter
                  _isChecking = _controller!.findSMI('isChecking');
                  _isHandsUp = _controller!.findSMI('isHandsUp');
                  _trigSuccess = _controller!.findSMI('trigSuccess');
                  _trigFail = _controller!.findSMI('trigFail');
                  _numLook = _controller!.findSMI('numLook');
                },
                )),
              const SizedBox(height: 10), //separación entre la animación y el campo de email
              TextField(
                //paso 1.3: asociar los focusNodes a los campos de texto
                focusNode: _emailFocusNode,
                onChanged: (value){
                 //asociamos el focusNode al campo de email
                  if(_isHandsUp != null){
                    //No tapes los ojos al ver email
                    //_isHandsUp!.change(false);
                  }
                  //Si isChecking no es null
                  if(_isChecking == null) return;

                  //Activar modo chismoso
                    _isChecking!.change(true);

                    //2.4 implementar numlook
                    //ajustes de limites de 0 a 100
                    //80 como medida de calibración

                    final look = (value.length/80.0*100.0).clamp(0.0, 100.0);//Clamp es el rango
                    _numLook?.value = look;

                    //3.3 Debounce: si vuelve a escribir, reinicia el timer
                    _typingDebounce?.cancel();
                    _typingDebounce = Timer(const Duration(seconds: 1), () {
                      if(!mounted) return;
                      //mirada neutra
                      _isChecking?.change(false);
                    });
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),//icono de email para el campo de email
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12) //borde redondeado para el campo de email
                  )
                ),
              ),
              const SizedBox(height: 10), //separación entre el campo de email y el campo de password
              TextField(
                //paso 1.3: asociar los focusNodes a los campos de texto
                focusNode: _passwordFocusNode,
                onChanged: (value){
                  if(_isChecking != null){
                    //No quiero modo chismoso
                    //_isChecking!.change(false);
                  }
                  //Si isHandsUp no es null
                  if(_isHandsUp == null) return;
                  //Levantar las manos al ver password
                    _isHandsUp!.change(true); 
                },
                obscureText: _obscureText, //ocultamos la contraseña por defecto  
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),//icono de candado para el campo de password
                  suffixIcon: IconButton(
                    //if ternario
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off, //cambiamos el icono de ojo dependiendo de si la contraseña está oculta o no
                    ),
                    onPressed: () {
                      //refresca el icono
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ), 
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)//borde redondeado para el campo de password
                  )
                ),
              ),
              const SizedBox(height: 10), //separación entre el campo de password y el botón de login
              ]
          ),
        )
      ),
    );
  }

  //paso 1.4: limpiar los focusNodes para evitar fugas de memoria
  @override
  void dispose() {
    //limpiar los focusNodes para evitar fugas de memoria
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce?.cancel(); //cancelar el timer de debounce para evitar fugas de memoria
    super.dispose();
  }
}