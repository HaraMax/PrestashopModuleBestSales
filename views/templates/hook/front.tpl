{if $display_sales[0]["best_sales"] == 1 && $categories_sale}
    <section class="category-best-sales">
        <h2>{l s="Nos meilleures ventes dans cette catégorie" mod="amcategsale"}</h2>
        <div class="products slick-products-carousel products-grid slick-default-carousel slick-arrows-{$iqitTheme.pl_crsl_style}"
            data-slick='{strip}
                {ldelim}
                "slidesToShow": 4,
                "autoplay": false,
                "dots": false,
                "responsive": [
                    {ldelim}
                    "breakpoint": 1100,
                    "settings":
                    {ldelim}
                    "slidesToShow": 3,
                    "slidesToScroll": 3
                    {rdelim}
                    {rdelim},
                    {ldelim}
                    "breakpoint": 575,
                    "settings":
                    {ldelim}
                    "slidesToShow": 2,
                    "slidesToScroll": 2
                    {rdelim}
                    {rdelim}
                ]
                {rdelim}{/strip}'
            >
                {foreach from=$categories_sale item="product" name=categories_sale}
                    {if $smarty.foreach.categories_sale.index < 8}
                        {block name='product_miniature_item'}
                            <div class="js-product-miniature-wrapper product-carousel">
                                <article
                                        class="product-miniature product-miniature-default product-miniature-grid product-miniature-layout-{$iqitTheme.pl_grid_layout} js-product-miniature"
                                        data-id-product="{$product.id_product}"
                                        data-id-product-attribute="{$product.id_product_attribute}"
                                        style="{if $product.quantity == '0' && ($product.qty_total == '0' || empty($product.qty_total))}opacity: 0.7;{/if}"

                                >

                                    {block name='product_thumbnail'}
                                        <div class="thumbnail-container">
                                            <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html" class="thumbnail product-thumbnail">

                                                {if $product.id_image}
                                                    <img
                                                            {if $iqitTheme.pl_lazyload}
                                                                {if isset($carousel) && $carousel}
                                                                    data-lazy="{$link->getImageLink($product.link_rewrite, $product.id_image, 'home_default')|escape:'html'}"
                                                                {else}
                                                                    data-src="{$link->getImageLink($product.link_rewrite, $product.id_image, 'home_default')|escape:'html'}"
                                                                    src="{$iqitTheme.theme_assets}img/blank.png"
                                                                {/if}
                                                            {else}
                                                                src="{$link->getImageLink($product.link_rewrite, $product.id_image, 'home_default')|escape:'html'}"
                                                            {/if}
                                                            alt="{if !empty($product.cover.legend)}{$product.cover.legend}{else}{$product.name|truncate:30:'...'}{/if}"
                                                            data-full-size-image-url="{$link->getImageLink($product.link_rewrite, $product.id_image, 'large_default')|escape:'html'}"
                                                            width="236"
                                                            height="305"
                                                            class="img-fluid {if $iqitTheme.pl_lazyload}{if isset($carousel) && $carousel} {else}js-lazy-product-image{/if}{/if} product-thumbnail-first{if $page.page_name == 'product'} lazyload{/if}"
                                                    >
                                                {else}
                                                    <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html" class="thumbnail product-thumbnail">
                                                        <img class="img-fluid product-thumbnail-first" src="{$urls.no_picture_image.bySize.home_default.url}"
                                                            alt="{if !empty($product.cover.legend)}{$product.cover.legend}{else}{$product.name|truncate:30:'...'}{/if}"
                                                            width="{$urls.no_picture_image.bySize.home_default.width}"
                                                            height="{$urls.no_picture_image.bySize.home_default.height}">
                                                {/if}

                                                {if !isset($overlay)}
                                                    {if $iqitTheme.pl_rollover}
                                                        {foreach from=$product.images item=image}
                                                            {if !$image.cover}
                                                                <img
                                                                    src="{$iqitTheme.theme_assets}img/blank.png"
                                                                    data-src="{$image.bySize.home_default.url}"
                                                                    width="{$image.bySize.home_default.width}"
                                                                    height="{$image.bySize.home_default.height}"
                                                                    alt="{if !empty($product.cover.legend)}{$product.cover.legend}{else}{$product.name|truncate:30:'...'}{/if} 2"
                                                                    class="img-fluid js-lazy-product-image product-thumbnail-second"
                                                                >
                                                                {break}
                                                            {/if}
                                                        {/foreach}
                                                    {/if}
                                                {/if}
                                            </a>

                                            <ul class="product-flags">
                                                {if isset($product.to) && $product.to != '0000-00-00 00:00:00'}
                                                    <li class="product-flag vente_flash"></li>
                                                {elseif isset($product.reduction) && $product.to == '0000-00-00 00:00:00'}
                                                    <li class="product-flag discount">-{$product.reduction|string_format:"%.2f"|replace:'.00':''} €</li>
                                                {/if}
                                            </ul>
                                            {if !isset($product.to) || $product.to == '0000-00-00 00:00:00'}
                                                {hook h='displayProductListReviews' product=$product mod="tagsicons"}
                                            {/if}

                                            {if !isset($overlay) && !isset($list)}
                                                <div class="product-functional-buttons product-functional-buttons-bottom">
                                                    <div class="product-functional-buttons-links">
                                                        {hook h='displayProductListFunctionalButtons' product=$product}
                                                            <a class="js-quick-view-iqit" href="#" data-link-action="quickview" data-toggle="tooltip"
                                                            title="{l s='Quick view' d='Shop.Theme.Actions'}">
                                                                <i class="fa fa-eye" aria-hidden="true"></i></a>
                                                    </div>
                                                </div>
                                            {/if}

                                            {if !isset($list)}
                                                <div class="product-availability d-block">
                                                    {if $product.quantity == '0' && ($product.qty_total == '0' || empty($product.qty_total))}
                                                        <span class="badge badge-danger product-unavailable mt-2">
                                                            <i class="fa fa-ban" aria-hidden="true"></i>
                                                            Victime de son succès
                                                        </span>
                                                    {/if}
                                                    {if $product.show_availability && $product.availability_message}
                                                        <span
                                                                class="badge {if $product.availability == 'available'} {if $product.quantity <= 0  && $product.allow_oosp} badge-danger product-unavailable product-unavailable-allow-oosp {else}badge-success product-available{/if}{elseif $product.availability == 'last_remaining_items'}badge-warning d-none product-last-items{else}badge-danger product-unavailable{/if} mt-2{if $product.availability_message == 'Produit disponible avec d\'autres options'} d-none{/if}">
                                                    {if $product.availability == 'available'}
                                                        <i class="fa fa-check rtl-no-flip" aria-hidden="true"></i>
                                                                                        {$product.availability_message}
                                                    {elseif $product.availability == 'last_remaining_items'}
                                                        <i class="fa fa-exclamation" aria-hidden="true"></i>
                                                                                        {$product.availability_message}
                                                    {else}
                                                        <i class="fa fa-ban" aria-hidden="true"></i>
                                                                {$product.availability_message}
                                                        {if isset($product.available_date) && $product.available_date != '0000-00-00'}
                                                        {if $product.available_date|strtotime > $smarty.now}<span
                                                                class="available-date">{l s='until' d='Shop.Theme.Catalog'} {$product.available_date}</span>{/if}
                                                    {/if}
                                                    {/if}
                                                    </span>
                                                    {/if}

                                                </div>
                                            {/if}

                                            <div class="miniature-achat-rapide">
                                                {hook h='displayAchatRapide' product=$product mod="stattributelist"}
                                                <div class="miniature-achat-rapide-no-decli">
                                                    <div class="miniature-achat-rapide-container">
                                                        <div class="st_attr_list_container">
                                                            <div class="st_attr_list_item">
                                                                <h2 class="st_attr_titre">{l s="Achat rapide" mod="stattributelist"}</h2>
                                                            </div>
                                                            <input
                                                                type="number"
                                                                name="qty"
                                                                value="1"
                                                                class="input-group"
                                                            >
                                                            <a class="achat-rapide-no-decli-btn">{l s="Ajouter au panier" mod="stattributelist"}</a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                        </div>
                                    {/block}

                                    {block name='product_description_block'}
                                        <div class="product-description">
                                            {block name='product_category_name'}
                                                {if $product.category_name != ''}
                                                    <div class="product-category-name text-muted">{$product.category_name}</div>
                                                {/if}
                                            {/block}

                                            {block name='product_name'}
                                                <h3 class="h3 product-title">
                                                    <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html">{$product.name|truncate:90:'...'}</a>
                                                </h3>
                                            {/block}

                                            {block name='product_brand'}
                                                {if isset($product.manufacturer_name ) && $product.manufacturer_name != ''}
                                                    <div class="product-brand text-muted"><a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html">{$product.manufacturer_name}</a></div>
                                                {/if}
                                            {/block}

                                            {block name='product_reference'}
                                                {if $product.reference != ''}
                                                    <div class="product-reference text-muted"><a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html">{$product.reference}</a></div>
                                                {/if}
                                            {/block}

                                            {block name='product_reviews'}
                                                {hook h='displayProductListReviews' product=$product}
                                            {/block}

                                            {block name='product_price_and_shipping'}
                                                {math equation="x * (1 + y / 100)" x=$product.price y=$product.rate|string_format:"%d" assign=regular_price format="%.2f"}
                                                {if $product.show_price}
                                                    <div class="product-price-and-shipping">
                                                        {hook h='displayProductPriceBlock' product=$product type="before_price"}
                                                        {if $product.reduction && $product.reduction_finie != true}
                                                            {math equation="x - (y * x)" x=$regular_price y=$product.reduction assign=price_discount_percentage}
                                                            {math equation="x - y" x=$regular_price y=$product.reduction assign=price_discount_amount}
                                                            {hook h='displayProductPriceBlock' product=$product type="old_price"}
                                                            {if $product.reduction_type === 'percentage'}
                                                                <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html"><span class="product-price" content="{$regular_price}">{$price_discount_percentage|string_format:"%.2f"|replace:".":","} €</span></a>
                                                            {elseif $product.reduction_type === 'amount'}
                                                                <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html"><span class="product-price" content="{$regular_price}">{$price_discount_amount|string_format:"%.2f"|replace:".":","} €</span></a>
                                                            {/if}
                                                            <span class="regular-price text-muted">{$regular_price|replace:".":","} €</span>
                                                        {else}
                                                            <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html"><span class="product-price" content="{$regular_price}">{$regular_price|replace:".":","} €</span></a>
                                                        {/if}
                                                        {hook h='displayProductPriceBlock' product=$product type='unit_price'}
                                                        {hook h='displayProductPriceBlock' product=$product type='weight'}
                                                        {if $product.reduction}
                                                            {hook h='displayCountDown'}
                                                        {/if}
                                                    </div>
                                                {/if}
                                            {/block}



                                            {block name='product_variants'}
                                                {if $product.main_variants}
                                                    <div class="products-variants">
                                                        {if $product.main_variants}
                                                            {include file='catalog/_partials/variant-links.tpl' variants=$product.main_variants}
                                                        {/if}
                                                    </div>
                                                {/if}
                                            {/block}

                                            {block name='product_description_short'}
                                                <div class="product-description-short text-muted">
                                                    <a href="{$urls.base_url}{$product.id_product}-{$product.id_product_attribute}-{$product.link_rewrite}.html">{$product.description_short|strip_tags:'UTF-8'|truncate:360:'...' nofilter}</a>
                                                </div>
                                            {/block}

                                            {block name='product_add_cart'}
                                                {include file='catalog/_partials/miniatures/_partials/product-miniature-btn.tpl'}
                                            {/block}

                                            {block name='product_add_cart_below'}
                                                {hook h='displayProductListBelowButton' product=$product}
                                            {/block}

                                        </div>
                                    {/block}


                                    {if isset($richData) && $richData}
                                        <span itemprop="isRelatedTo"  itemscope itemtype="https://schema.org/Product" >
                                    {if $product.cover}
                                        <meta itemprop="image" content="{$product.cover.medium.url}">
                                    {else}
                                        <meta itemprop="image" content="{$urls.no_picture_image.bySize.home_default.url}">
                                    {/if}

                                    <meta itemprop="name" content="{$product.name}"/>
                                    <meta itemprop="url" content="{$product.canonical_url}"/>
                                    <meta itemprop="description" content="{$product.description_short|strip_tags:'UTF-8'|truncate:360:'...'}"/>

                                    <span itemprop="offers" itemscope itemtype="https://schema.org/Offer" >
                                        {if isset($currency.iso_code)}
                                            <meta itemprop="priceCurrency" content="{$currency.iso_code}">
                                        {/if}
                                        <meta itemprop="price" content="{$product.price_amount}"/>
                                    </span>
                                    </span>
                                    {/if}

                                </article>
                            </div>
                        {/block}
                    {/if}
                {/foreach}
            </div>
    </section>
{/if}