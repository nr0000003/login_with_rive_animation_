import 'package:flutter/material.dart';
import 'package:rive/rive.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
//crear variable para mostrar u ocultar la contraseña
  bool _obscureText = true;

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
                child: RiveAnimation.asset('animated_login_bear.riv')),//agregamos la animación de Rive en la parte superior de la pantalla
              const SizedBox(height: 10), //separación entre la animación y el campo de email
              TextField(
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
}