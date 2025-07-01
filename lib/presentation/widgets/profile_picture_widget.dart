// lib/presentation/widgets/profile_picture_widget.dart
// ============================================================================
// WIDGET REUTILIZABLE PARA MOSTRAR FOTO DE PERFIL
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';

// Modelos
import '../../data/models/optimized_models.dart';

// Componentes modernos
import '../screens/components/modern_design_system.dart';

class ProfilePictureWidget extends StatelessWidget {
  final OptimizedUserModel user;
  final double size;
  final bool showBorder;
  final bool showOnlineIndicator;
  final VoidCallback? onTap;
  final List<Color>? borderColors;
  final double borderWidth;

  const ProfilePictureWidget({
    super.key,
    required this.user,
    this.size = 60,
    this.showBorder = true,
    this.showOnlineIndicator = false,
    this.onTap,
    this.borderColors,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: showBorder
              ? LinearGradient(
            colors: borderColors ?? [
              const Color(0xFF3B82F6), // Azul
              const Color(0xFF8B5CF6), // Púrpura
              const Color(0xFF10B981), // Verde
              const Color(0xFFF59E0B), // Amarillo
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: showBorder ? null : Colors.grey.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenedor interno con la imagen/emoji
            Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(showBorder ? borderWidth : 0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: _buildAvatarContent(),
                ),
              ),
            ),

            // Indicador de estado online (opcional)
            if (showOnlineIndicator)
              Positioned(
                bottom: size * 0.05,
                right: size * 0.05,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    // Si tiene foto de perfil y el archivo existe
    if (user.hasProfilePicture) {
      return Image.file(
        File(user.profilePicturePath!),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          // Si hay error cargando la imagen, mostrar emoji como fallback
          return _buildEmojiAvatar();
        },
      );
    } else {
      // Mostrar emoji avatar
      return _buildEmojiAvatar();
    }
  }

  Widget _buildEmojiAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: ModernColors.primaryGradient,
        ),
      ),
      child: Center(
        child: Text(
          user.avatarEmoji,
          style: TextStyle(
            fontSize: size * 0.4, // 40% del tamaño del container
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// WIDGET ESPECIALIZADO PARA DIFERENTES TAMAÑOS
// ============================================================================

class SmallProfilePicture extends StatelessWidget {
  final OptimizedUserModel user;
  final VoidCallback? onTap;

  const SmallProfilePicture({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      user: user,
      size: 40,
      borderWidth: 2,
      onTap: onTap,
    );
  }
}

class MediumProfilePicture extends StatelessWidget {
  final OptimizedUserModel user;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;

  const MediumProfilePicture({
    super.key,
    required this.user,
    this.onTap,
    this.showOnlineIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      user: user,
      size: 60,
      showOnlineIndicator: showOnlineIndicator,
      onTap: onTap,
    );
  }
}

class LargeProfilePicture extends StatelessWidget {
  final OptimizedUserModel user;
  final VoidCallback? onTap;

  const LargeProfilePicture({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      user: user,
      size: 120,
      borderWidth: 4,
      onTap: onTap,
    );
  }
}

// ============================================================================
// WIDGET PARA PLACEHOLDER CUANDO NO HAY USUARIO
// ============================================================================

class ProfilePicturePlaceholder extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final String text;

  const ProfilePicturePlaceholder({
    super.key,
    this.size = 60,
    this.onTap,
    this.text = '?',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.3),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: size * 0.4,
              color: Colors.grey.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}