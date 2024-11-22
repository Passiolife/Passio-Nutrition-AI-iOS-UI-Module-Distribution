//
//  Strings+Constants.swift
//
//
//  Created by Nikunj Prajapati on 09/08/24.
//

import Foundation

// MARK: - DateFormat String
enum DateFormatString {
    static let mmmm_dd_yyyy = "MMMM dd, yyyy"
    static let EEEE_MMM_dd_yyyy = "EEEE MMM dd yyyy"
    static let MMMM_yyyy = "MMMM - yyyy"
    static let yyyy_MM_dd = "yyyy/MM/dd"
    static let h_mm_a = "h:mm a"
    static let HH_mm = "HH.mm"
    static let HHmm = "HH:mm"
    static let MM_dd_yyyy_E = "MM/dd/yyyy | E"
    static let M_d_yyyy = "M-d-yyyy"
    static let M_d_yyyy2 = "M/d/yyyy"
    static let yyyyMMdd = "yyyyMMdd"
    static let EEEMMMddYYYYhmma = "EEE, MMM dd YYYY, h:mm a"
    static let EEE_MMMd = "EEE, MMM d"
}

// MARK: - Constants
public struct ToastMessages {
    public static let addedToLog = "Added to Log"
    public static let removedFavorite = "Removed from Favorites"
    public static let addedFavorite = "Added to Favorites"
}

public struct ButtonTexts {
    public static let save = "Save"
    public static let delete = "Delete"
    public static let edit = "Edit"
    public static let cancel = "Cancel"
    public static let log = "Log"
    public static let details = "Details"
    public static let ok = "Ok"
    public static let addIngredient = "Add Ingredient"
    public static let today = "Today"
}

public struct UnitsTexts {
    public static let cGrams = "Grams"
    public static let grams = "grams"
    public static let gram = "gram"
    public static let g = "g"
    public static let mg = "mg"
    public static let mcg = "μg"
    public static let iu = "IU"
    public static let cal = "cal"
    public static let ml = "ml"
    public static let serving = "Serving"
    public static let piece = "Piece"
    public static let cup = "Cup"
    public static let oz = "Oz"
    public static let small = "Small"
    public static let medium = "Medium"
    public static let large = "Large"
    public static let handful = "Handful"
    public static let scoop = "Scoop"
    public static let tbsp = "Tbsp"
    public static let tsp = "Tsp"
    public static let slice = "Slice"
    public static let can = "Can"
    public static let bottle = "Bottle"
    public static let bar = "Bar"
    public static let packet = "Packet"
}

public struct NutritionsTexts {
    public static let calories = "Calories"
    public static let carbs = "Carbs"
    public static let protein = "Protein"
    public static let fat = "Fat"
}

public struct RecipeTexts {
    public static let recipeTitle = "Recipe"
    public static let createRecipe = "Create Recipe"
    public static let editRecipe = "Edit Recipe"
    public static let makeCustomRecipe = "Make Custom Recipe"
    public static let createUserRecipeTitle = "Create User Recipe?"
    public static let createUserRecipeSubTitle = "You are about to create a user recipe from this food"

    public static let createOrEditUserRecipeTitle = "Create or Edit User Recipe?"
    public static let createOrEditUserRecipeSubTitle = "Do you want to create a new user recipe based off this one, or edit the existing recipe?"
}

public struct UserFoodTexts {
    public static let userFoodTitle = "userFood"
    public static let createUserFoodTitle = "Create User Food?"
    public static let createUserFoodSubTitle = "You are about to create a user food from this food"

    public static let createOrEditUserFoodTitle = "Create or Edit User Food?"
    public static let createOrEditUserFoodSubTitle = "Do you want to create a new user food based off this one, or edit the existing user food?"
}

public struct FoodDetailsTexts {
    public static let foodDetails = "Food Details"
}
