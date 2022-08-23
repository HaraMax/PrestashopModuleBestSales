<?php
/**
 * AM Suivi des commandes en rupture
 *
 * @author    Arnaud Merigeau <contact@arnaud-merigeau.fr> - https://www.arnaud-merigeau.fr
 * @copyright Arnaud Merigeau 2020 - https://www.arnaud-merigeau.fr
 * @license   Commercial
 * @version   1.0.0
 *
 */

use PrestaShopBundle\Form\Admin\Type\SwitchType;

if (!defined('_PS_VERSION_')) {
    exit;
}

class AMcategsale extends Module
{
    public function __construct()
    {
        $this->name = 'amcategsale';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'LATOUTFRANCAIS - Arnaud Merigeau';
        $this->need_instance = 0;

        $this->context = Context::getContext();
        $this->bootstrap = true;
        parent::__construct();

        $this->displayName = $this->l('(AM) Categ Sale');
        $this->description = $this->l('Meilleure vente par catégorie');
        $this->confirmUninstall = $this->l('Are you sure you want to uninstall this module ?');
    }

    public function install()
    {
        if (!parent::install()
            //Installation des hooks
            || !$this->registerHook([
                'displayCategorySales',
                'actionCategoryFormBuilderModifier',
                'actionAfterCreateCategoryFormHandler',
                'actionAfterUpdateCategoryFormHandler',
                'displayAdminProductsMainStepLeftColumnBottom',
            ])
        ) {
            return false;
        }
 
        return true;
    }

    public function uninstall()
    {
        return parent::uninstall();
    }

    public function getContent()
    {

        
    }

    public function hookdisplayCategorySales($params)
    {
        $result = array();
        $categories_sale = array();
        $categories_sale_select = array();
        $categories_child = array();
        $sub_sub_categ = array();
        $final_array = [];
        $id_current_category = Tools::getValue('id_category');
        
        $context = Context::getContext();
        $idLang = $this->context->language->id;
        $categories_child = Category::getChildren($id_current_category, $idLang);
        foreach($categories_child as $key => $subcateg){
            array_push($sub_sub_categ, Category::getChildren($subcateg["id_category"], $idLang));
        }

        foreach($sub_sub_categ as $key => $value){
            foreach($value as $subvalue){
                array_push($final_array, $subvalue["id_category"]);
            }
        }

        $query = 'SELECT best_sales FROM ' . _DB_PREFIX_ . 'category_lang WHERE id_category = ' . $id_current_category;
        $display_sales = Db::getInstance()->executeS($query);

        $date_now = date("Y-m-d H:i:s");

        $sql_select = 'SELECT p.*, product_shop.*,
                        ' . (Combination::isFeatureActive() ? 'product_attribute_shop.default_on,product_attribute_shop.minimal_quantity AS product_attribute_minimal_quantity,IFNULL(product_attribute_shop.id_product_attribute,0) id_product_attribute,' : '') . '
                        pl.`description`, pl.`description_short`, pl.`link_rewrite`, pl.`meta_description`,
                        image_shop.`id_image` id_image, il.`legend`,
                        ps.`quantity` AS sales, t.`rate`, pl.`meta_keywords`, pl.`meta_title`, pl.`meta_description`,
                        spep.`reduction`, spep.`reduction_type`, spep.`to`,
                        pl.`meta_keywords`, pl.`meta_title`, pl.`name`, pl.`available_now`, pl.`available_later`
                        FROM '._DB_PREFIX_.'product p
                        LEFT JOIN '._DB_PREFIX_.'product_extra_field field
                        ON p.`id_product` = field.`id_product`
                        LEFT JOIN '._DB_PREFIX_.'product_sale ps
                        ON p.`id_product` = ps.`id_product`
                        LEFT JOIN '._DB_PREFIX_.'product_lang pl
                        ON p.`id_product` = pl.`id_product`
                        LEFT JOIN '._DB_PREFIX_.'image_shop image_shop
                        ON (image_shop.`id_product` = p.`id_product` AND image_shop.cover=1 AND image_shop.id_shop=' . (int) $context->shop->id . ')
                        LEFT JOIN '._DB_PREFIX_.'image_lang il ON (image_shop.`id_image` = il.`id_image` AND il.`id_lang` = ' . (int) $idLang . ')
                        LEFT JOIN '._DB_PREFIX_.'manufacturer m ON (m.`id_manufacturer` = p.`id_manufacturer`)
                        LEFT JOIN '._DB_PREFIX_.'product_shop shop
                        ON p.`id_product` = shop.`id_product`
                        LEFT JOIN '._DB_PREFIX_.'tax_rule tr 
                        ON shop.`id_tax_rules_group` = tr.`id_tax_rules_group`
                        AND tr.`id_country` = ' . (int) $context->country->id . '
                        AND tr.`id_state` = 0
                        LEFT JOIN '._DB_PREFIX_.'tax t
                        ON t.`id_tax` = tr.`id_tax`
                        LEFT JOIN '._DB_PREFIX_.'specific_price spep
                        ON p.`id_product` = spep.`id_product`
                        ' . Shop::addSqlAssociation('product', 'p', false);
                        if (Combination::isFeatureActive()) {
                            $sql_select .= 'LEFT JOIN '._DB_PREFIX_.'product_attribute_shop product_attribute_shop
                            ON (p.`id_product` = product_attribute_shop.`id_product` AND product_attribute_shop.`default_on` = 1 AND product_attribute_shop.id_shop=' . (int) $context->shop->id . ')';
                        }
                        $sql_select .= 'WHERE field.`best_sale` = 1';
        $result_select = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($sql_select);
        foreach($result_select as $key => $array_select){
            if(in_array($id_current_category, Product::getProductCategories($array_select["id_product"])) || array_search($array_select["id_category_default"], array_column($categories_child, 'id_category')) !== false || in_array($array_select["id_category_default"], $final_array)){
                if(!is_null($array_select["to"])){
                    if($array_select["to"] == "0000-00-00 00:00:00" || $array_select["to"] > $date_now){
                        array_push($categories_sale_select, $array_select);
                    }
                    else{
                        $array_select['reduction_finie'] = true;
                        array_push($categories_sale_select, $array_select);
                    }
                }
                else{
                    array_push($categories_sale_select, $array_select);
                }
                array_push($categories_sale_select, $array_select);
            }
        }

        $sql = 'SELECT p.*, product_shop.*, stock.out_of_stock, IFNULL(stock.quantity, 0) as quantity,
                    ' . (Combination::isFeatureActive() ? 'product_attribute_shop.minimal_quantity AS product_attribute_minimal_quantity,IFNULL(product_attribute_shop.id_product_attribute,0) id_product_attribute,' : '') . '
                    pl.`description`, pl.`description_short`, pl.`link_rewrite`, pl.`meta_description`,
                    pl.`meta_keywords`, pl.`meta_title`, pl.`name`, pl.`available_now`, pl.`available_later`,
                    m.`name` AS manufacturer_name, p.`id_manufacturer` as id_manufacturer,
                    image_shop.`id_image` id_image, il.`legend`,
                    ps.`quantity` AS sales, t.`rate`, pl.`meta_keywords`, pl.`meta_title`, pl.`meta_description`,
                    spep.`reduction`, spep.`reduction_type`, spep.`to`'
            . ' FROM `' . _DB_PREFIX_ . 'product_sale` ps
                LEFT JOIN `' . _DB_PREFIX_ . 'product` p ON ps.`id_product` = p.`id_product`
                ' . Shop::addSqlAssociation('product', 'p', false);
        if (Combination::isFeatureActive()) {
            $sql .= ' LEFT JOIN `' . _DB_PREFIX_ . 'product_attribute_shop` product_attribute_shop
                            ON (p.`id_product` = product_attribute_shop.`id_product` AND product_attribute_shop.`default_on` = 1 AND product_attribute_shop.id_shop=' . (int) $context->shop->id . ')';
        }

        $sql .= ' LEFT JOIN `' . _DB_PREFIX_ . 'product_lang` pl
                    ON p.`id_product` = pl.`id_product`
                    AND pl.`id_lang` = ' . (int) $idLang . Shop::addSqlRestrictionOnLang('pl') . '
                LEFT JOIN `' . _DB_PREFIX_ . 'image_shop` image_shop
                    ON (image_shop.`id_product` = p.`id_product` AND image_shop.cover=1 AND image_shop.id_shop=' . (int) $context->shop->id . ')
                LEFT JOIN `' . _DB_PREFIX_ . 'image_lang` il ON (image_shop.`id_image` = il.`id_image` AND il.`id_lang` = ' . (int) $idLang . ')
                LEFT JOIN `' . _DB_PREFIX_ . 'manufacturer` m ON (m.`id_manufacturer` = p.`id_manufacturer`)
                LEFT JOIN `' . _DB_PREFIX_ . 'tax_rule` tr ON (product_shop.`id_tax_rules_group` = tr.`id_tax_rules_group`)
                    AND tr.`id_country` = ' . (int) $context->country->id . '
                    AND tr.`id_state` = 0
                LEFT JOIN `' . _DB_PREFIX_ . 'specific_price` spep
                ON p.`id_product` = spep.`id_product`
                LEFT JOIN '._DB_PREFIX_.'product_extra_field field
                ON p.`id_product` = field.`id_product`
                LEFT JOIN `' . _DB_PREFIX_ . 'tax` t ON (t.`id_tax` = tr.`id_tax`)
                ' . Product::sqlStock('p', 0);

        $sql .= '
                WHERE product_shop.`active` = 1
                    AND product_shop.`visibility` != \'none\'
                    AND p.`quantity` != 0
                    ORDER BY ps.`sale_nbr` DESC';


        $result = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS($sql);
        $i = 0;

        foreach($result as $key => $array){
            if(in_array($id_current_category, Product::getProductCategories($array["id_product"])) || array_search($array["id_category_default"], array_column($categories_child, 'id_category')) !== false || in_array($array["id_category_default"], $final_array) || array_search($id_current_category, array_column(Product::getProductCategoriesFull($array["id_product"]), 'id_category'))){
                $query_qty_total = 'SELECT SUM(quantity) FROM ' . _DB_PREFIX_ . 'product_attribute WHERE id_product = ' . $array["id_product"] . ' AND quantity >= 0';
                $qty_total = Db::getInstance()->executeS($query_qty_total);
                if(!is_null($array["to"])){
                    if($array["to"] == "0000-00-00 00:00:00" || $array["to"] > $date_now){
                        array_push($categories_sale, $array);
                        $categories_sale[$i]["qty_total"] = $qty_total[0]["SUM(quantity)"];
                        $i++;
                    }
                    else{
                        array_push($categories_sale, $array);
                        $categories_sale[$i]["qty_total"] = $qty_total[0]["SUM(quantity)"];
                        $categories_sale[$i]['reduction_finie'] = true;
                        $i++;
                    }
                }
                else{
                    array_push($categories_sale, $array);
                    $categories_sale[$i]["qty_total"] = $qty_total[0]["SUM(quantity)"];
                    $i++;
                }
            }
        }
        
        $result_final = array_merge($categories_sale_select, $categories_sale);
        //Supprimer doublon
        $result_final_no_double = $this->unique_key($result_final, "id_product");
        $this->smarty->assign(array(
            'categories_sale' => $result_final_no_double,
            'display_sales' => $display_sales,
            'categories_sale_select' => $categories_sale_select
        ));

        return $this->display(__FILE__, 'front.tpl');
    }


    public function hookActionCategoryFormBuilderModifier(array $params)
    {
        //Récupération du form builder
        /** @var \Symfony\Component\Form\FormBuilder $formBuilder */
        $formBuilder = $params['form_builder'];
 
 
        //Ajout de notre champ spécifique
        $formBuilder->add('best_sales',
            //Cf génériques symonfy https://symfony.com/doc/current/reference/forms/types.html
            // et spécificiques prestashop https://devdocs.prestashop.com/1.7/development/components/form/types-reference/
            SwitchType::class,
            [
                'label' => $this->l('Meilleures ventes'), //Label du champ
                'required' => false, //Requis ou non
                'choices' => [
                    'NON' => false,
                    'OUI' => true,
                ],
                //La valeur peut être setée ici
                
            ]
        );
        
        $query = 'SELECT best_sales FROM ' . _DB_PREFIX_ . 'category_lang WHERE id_category = ' . $params['id'];
        $test = Db::getInstance()->executeS($query);
        $params['data']['best_sales'] = $test[0]["best_sales"];
 
        //Il faut bien penser à mettre cette ligne pour mettre à jour les données au formulaire
        $formBuilder->setData($params['data']);
    }

    public function hookActionAfterCreateCategoryFormHandler(array $params)
    {
        $this->updateData($params['id'],$params['form_data']);
    }

    public function hookActionAfterUpdateCategoryFormHandler(array $params)
    {
        $this->updateData($params['id'],$params['form_data']);
    }

    protected function updateData(int $id_category,array $data)
    {
        //Réalisation du traitement de mise à jour
        $query = "UPDATE `"._DB_PREFIX_."category_lang` SET best_sales='".$data['best_sales']."' WHERE id_category = '".$id_category."' ";
        Db::getInstance()->Execute($query);
    }

    public function unique_key($array, $keyname){
        $news_array = array();
        foreach($array as $key => $value){
            if(!isset($new_array[$value[$keyname]])){
                $new_array[$value[$keyname]] = $value;
            }
        }
        $new_array = array_values($new_array);
    return $new_array;
    }
}
