/*
 * Copyright 2009 Denys Pavlov, Igor Azarnyi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package org.yes.cart.web.page.component.product;

import org.yes.cart.domain.dto.ProductSearchResultDTO;

import java.util.List;

/**
 * Product association panel, that can show configured from markup
 * associations like cross/up/accessories/sell/etc
 * <p/>
 * Igor Azarny iazarny@yahoo.com
 * Date: 16-Sep-2011
 * Time: 15:36:10
 */
public class ProductAssociationsView extends AbstractProductSearchResultList {

    private List<ProductSearchResultDTO> associatedProductList = null;

    /**
     * Construct product association view.
     *
     * @param id              component id
     * @param associatedProductList associated list
     */
    public ProductAssociationsView(final String id, final List<ProductSearchResultDTO> associatedProductList) {
        super(id, true);
        this.associatedProductList = associatedProductList;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<ProductSearchResultDTO> getProductListToShow() {
        return associatedProductList;
    }

}
