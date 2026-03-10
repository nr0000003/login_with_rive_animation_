import 'package:flutter/material.dart';
import 'dart:async'; //3.1 Importa un timer
import 'package:rive/rive.dart'
    show
        Artboard,
        RiveAnimation,
        SMIBool,
        SMINumber,
        SMITrigger,
        StateMachineController;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;

  StateMachineController? _controller;

  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _triggerSuccess;
  SMITrigger? _triggerFail;

  //2.1 Variable para el recorrido de los ojos
  SMINumber? _numLook;

  //1.1) craear variables para FocusNode
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  //3.2 Timaer para detener miradada al dejar de escribir
  Timer? _typingDebounce;

  //crear los controllers para manipular el texto escrito
  // 4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // 4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // 4.4 Acción al botón
  void _onLogin() {
    //De lo que me dio el usuario, quitar espacios en blanco
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Recalcular errores
    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError = isValidPassword(pass)
        ? null
        : 'Mínimo 8 caracteres, 1 mayúscula,  1 minúscula, 1 número y 1 caracter especial';

    // 4.5 Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // 4.6 Cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; // Mirada neutral

    // 4.7 Activar triggers
    if (eError == null && pError == null) {
      _triggerSuccess?.fire();
    } else {
      _triggerFail?.fire();
    }
  }

  //1.2) agregar listeners a los FocusNode en initState (oyentes/chismosos)
  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        //verifica que no sea nulo
        if (_isHandsUp != null) {
          //Manos abajo en el email
          _isHandsUp?.change(false);
          //2.2) ojos mirando al frente
          _numLook?.value = 50.0;
        }
      }
    });

    _passwordFocusNode.addListener(() {
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      //Evita que se quite el espacio de nudget
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'animated_login_bear.riv',
                  stateMachines: const ['Login Machine'],
                  onInit: (Artboard artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );

                    if (_controller == null) return;

                    artboard.addController(_controller!);

                    _isChecking =
                        _controller!.findSMI('isChecking') as SMIBool?;
                    _isHandsUp =
                        _controller!.findSMI('isHandsUp') as SMIBool?;
                    _triggerSuccess =
                        _controller!.findSMI('trigSuccess') as SMITrigger?;
                    _triggerFail =
                        _controller!.findSMI('trigFail') as SMITrigger?;
                    //2.3 vincular numLook con el controlador
                    _numLook =
                        _controller!.findSMI('numLook') as SMINumber?;
                  },
                ),
              ),

              const SizedBox(height: 10),

              //Campo de texto email
              TextField(
                controller: emailCtrl,

                //1.3) asignar el FocusNode al TextField
                focusNode: _emailFocusNode,
                onChanged: (value) {
                  if (_isHandsUp != null) {}

                  if (_isChecking != null) {
                    _isChecking!.value = true;

                    //2.4 Implementar numLook
                    final look = (value.length / 80.0 * 100).clamp(0, 100);

                    _numLook?.value = look.toDouble();

                    //3.3 Reiniciar el timer cada vez que se escribe
                    _typingDebounce?.cancel();

                    _typingDebounce = Timer(
                      const Duration(milliseconds: 800),
                      () {
                        if (!mounted) return;

                        _isChecking?.change(false);
                      },
                    );
                  }
                },
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: emailError,
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //Campo de texto password
              TextField(
                //1.3) asignar el FocusNode al TextField
                focusNode: _passwordFocusNode,
                controller: passCtrl,
                onChanged: (value) {
                  if (_isChecking != null) {}

                  if (_isHandsUp != null) {
                    _isHandsUp!.value = true;
                  }
                }, //  ESTA COMA FALTABA (línea 104)

                obscureText: _isObscured,
                decoration: InputDecoration(
                  errorText: passError,
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),

              SizedBox(height: 10),

              //Texto "OLVIDASTE TU CONTRASEÑA?"
              SizedBox(
                width: size.width,
                child: const Text(
                  'Forgot password?',
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),

              SizedBox(height: 10),

              MaterialButton(
                //Toma todo el ancho disponible
                minWidth: size.width,
                height: 50,
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _onLogin,
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

              SizedBox(height: 20),

              //No tienes cuenta? Registrate
              SizedBox(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Don't have an account?"),
                    SizedBox(width: 5),
                    Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //1.4 liberar memoria
  @override
  void dispose() {
    //4.11 liberar los controllers
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}