// Example Definition (Place this in an appropriate file, e.g., lib/core/config/active_modules.dart)
import 'package:erp/features/auth/data/entities/activeModles/active_modules_entity.dart';

class ActiveModules {
  // Static map to hold module status.
  // Key: moduleId (int)
  // Value: 1 for active, 0 for inactive (based on your requirement list[moduleId]=1)
  static Map<int, int> activeModules = {};

  // Optional: Helper function to check status (returns 0 if module ID not found)
  static bool isModuleActive(int moduleId) {
    return activeModules[moduleId] == 1;
  }

  // Optional: Function to clear the map (useful on logout)
  static void clear() {
    print("Clearing Active Modules map.");
    activeModules.clear();
  }

  // Function to initialize or update the map from the fetched list
  static void updateFrom(List<CompanyModuleEntity> modules) {
    clear(); // Clear old values first
    print("Updating Active Modules map from fetched data...");
    for (var module in modules) {
      activeModules[module.moduleId] = module.isActive ? 1 : 0;
       print(" -> Module ID: ${module.moduleId}, Status: ${activeModules[module.moduleId]}");
    }
    print("Active Modules map updated: $activeModules");
  }
}

// You also need the CompanyModuleEntity definition accessible here or imported
// Assuming it's defined elsewhere and imported:
// import 'package:erp/features/auth/data/entities/activeModles/active_modules_entity.dart';