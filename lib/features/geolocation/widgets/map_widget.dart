import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../models/provider_model.dart';

class MapWidget extends StatelessWidget {
  final double userLatitude;
  final double userLongitude;
  final List<ProviderModel> providers;
  final Function(ProviderModel)? onProviderTap;
  final bool isUsingCep;
  final String? addressInfo;

  const MapWidget({
    Key? key,
    required this.userLatitude,
    required this.userLongitude,
    required this.providers,
    this.onProviderTap,
    this.isUsingCep = false,
    this.addressInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Informação do endereço quando usando CEP
          if (isUsingCep && addressInfo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.vinhoMedioUniodonto.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: AppColors.vinhoMedioUniodonto.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.vinhoMedioUniodonto,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      addressInfo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.vinhoMedioUniodonto,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

          // Mapa
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                isUsingCep && addressInfo != null ? 0 : 12,
              ),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(userLatitude, userLongitude),
                  zoom: 16.0,
                  maxZoom: 18.0,
                  minZoom: 10.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'uniodontopoa',
                  ),

                  // Primeiro os marcadores dos provedores (ficarão abaixo)
                  MarkerLayer(
                    markers: providers
                        .map(
                          (provider) => Marker(
                            point: LatLng(
                              provider.latitude,
                              provider.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                if (onProviderTap != null) {
                                  onProviderTap!(provider);
                                }
                              },
                              child: Image.asset(
                                'assets/icon/PIN-Uniodonto.png',
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Círculo mostrando o raio de 5km
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(userLatitude, userLongitude),
                        radius: 5000,
                        useRadiusInMeter: true,
                        color: Colors.blue.withOpacity(0.1),
                        borderColor: Colors.blue.withOpacity(0.3),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),

                  // Por último o marcador do usuário (ficará por cima)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(userLatitude, userLongitude),
                        width: 35,
                        height: 35,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            // Ícone diferente dependendo se está usando CEP ou GPS
                            isUsingCep ? Icons.location_pin : Icons.my_location,
                            color: AppColors.vinhoMedioUniodonto,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
